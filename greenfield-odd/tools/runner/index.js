// tools/runner/index.js
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import YAML from "yaml";
import xlsx from "xlsx";
import { z } from "zod";

const args = parseArgs(process.argv.slice(2));

const OLLAMA_URL = process.env.OLLAMA_URL || "http://localhost:11434";
const MODELS = {
  llama: process.env.ODD_MODEL_LLAMA || "llama3.1:8b",
  qwen: process.env.ODD_MODEL_QWEN || "qwen2.5-coder:14b",
};

const ROOT = process.cwd();
const INPUT_PATH = args.input;
if (!INPUT_PATH) {
  console.error(
    "Uso: node tools/runner/index.js --input ./inputs/event_mapping_completo_ODD_v3.xlsx"
  );
  process.exit(1);
}

const ARTIFACTS = {
  specDir: path.join(ROOT, "artifacts", "spec"),
  plansDir: path.join(ROOT, "artifacts", "plans"),
  logsDir: path.join(ROOT, "artifacts", "logs"),
  o11yYaml: path.join(ROOT, "artifacts", "spec", "o11y.yaml"),
  o11yJson: path.join(ROOT, "artifacts", "spec", "o11y.json"),
  oddSpecJson: path.join(ROOT, "artifacts", "spec", "odd_spec.json"),
  archPlanJson: path.join(ROOT, "artifacts", "plans", "architecture_plan.json"),
  generatedRoot: path.join(ROOT, "apps", "generated"),
  codegenManifest: path.join(ROOT, "artifacts", "plans", "codegen_manifest.json"),
};

ensureDirs([ARTIFACTS.specDir, ARTIFACTS.plansDir, ARTIFACTS.logsDir, ARTIFACTS.generatedRoot]);

// ---- Schema do XLSX v3 (gate local sem LLM) ----
const V3RowSchema = z.object({
  Ordem: z.union([z.number(), z.string()]),
  Caminho: z.string().min(1),
  "Tipo (Protagonista/Coadjuvante)": z.string().min(1),
  Evento: z.string().min(1),
  "EventNameId (sugestão)": z.string().min(1),
  Cor: z.string().min(1),
  "Bounded Context": z.string().min(1),
  Aggregate: z.string().min(1),
  "Comando Associado": z.string().min(1),
  "Touchpoint (HTTP/Queue/Internal)": z.string().min(1),
  "Rota ou Tópico": z.string().min(1),
  "Business Keys": z.string().min(1),
  "Sistema (SOR/PSP/Integration)": z.string().min(1),
  "Descrição Técnica": z.string().optional().default(""),
});

const ParsedSpecSchema = z.object({
  ok: z.boolean(),
  errors: z.array(z.object({ path: z.string(), message: z.string() })).default([]),
  o11y: z.any().optional(),
  oddSpec: z.any().optional(),
});

async function main() {
  console.log("== ODD GreenField Runner (v3) ==");
  console.log("Models:", MODELS);
  await assertOllamaUp();

  // 0) Carrega XLSX v3 -> JSON validado localmente
  const eventMappingV3 = loadEventMappingV3(INPUT_PATH);
  console.log(`Input rows: ${eventMappingV3.rows.length} (sheet: ${eventMappingV3.sheet})`);

  // 1) XLSX v3 -> o11y.yaml (Llama)
  const p1 = loadPrompt("01_xlsx_v3_to_o11y.md").replace(
    "{{EVENT_MAPPING_V3_JSON}}",
    JSON.stringify(eventMappingV3, null, 2)
  );

  console.log("\n[1/3] Gerando o11y.yaml a partir do XLSX v3...");
  const o11yYamlRaw = await ollamaGenerateText(MODELS.llama, p1);

  // >>> CORREÇÃO: extrai YAML puro (remove texto e ```yaml)
  const o11yYaml = extractYaml(o11yYamlRaw);

  // Valida YAML básico
  const o11yObj = safeParseYaml(o11yYaml);

  writeFile(ARTIFACTS.o11yYaml, o11yYaml);
  writeFile(ARTIFACTS.o11yJson, JSON.stringify(o11yObj, null, 2));
  console.log("  -> artifacts/spec/o11y.yaml");
  console.log("  -> artifacts/spec/o11y.json");

  // 2) Parse/normalização (Qwen) -> odd_spec.json
  console.log("\n[2/3] Parse/Normalização do o11y.yaml -> odd_spec.json...");
  const p2 = loadPrompt("02_parse_o11y_to_spec.md").replace("{{O11Y_YAML}}", o11yYaml);

  const parsedRaw = await ollamaGenerateJson(MODELS.qwen, p2);
  const parsed = ParsedSpecSchema.parse(parsedRaw);

  if (!parsed.ok) {
    writeFile(path.join(ARTIFACTS.logsDir, "parse_errors.json"), JSON.stringify(parsed, null, 2));
    console.error("  ✖ Parser retornou ok=false. Veja artifacts/logs/parse_errors.json");
    process.exit(2);
  }

  writeFile(ARTIFACTS.oddSpecJson, JSON.stringify(parsed.oddSpec ?? {}, null, 2));
  console.log("  -> artifacts/spec/odd_spec.json");

  // 3) Plano de arquitetura (Llama) -> architecture_plan.json
  console.log("\n[3/3] Gerando plano de arquitetura (NestJS)...");
  const oddSpecText = fs.readFileSync(ARTIFACTS.oddSpecJson, "utf8");
  const p3 = loadPrompt("03_plan_architecture.md").replace("{{ODD_SPEC_JSON}}", oddSpecText);

  const archPlan = await ollamaGenerateJson(MODELS.llama, p3);
  writeFile(ARTIFACTS.archPlanJson, JSON.stringify(archPlan, null, 2));
  console.log("  -> artifacts/plans/architecture_plan.json");

  console.log("\n✅ Fluxo inicial concluído (v3).");
  
  // 4) NestJS Code Generator (Qwen) -> apps/generated/*
  console.log("\n[4/4] Gerando código NestJS (apps/generated/*) com Qwen...");

  const archPlanText = fs.readFileSync(ARTIFACTS.archPlanJson, "utf8");
  const oddSpecText2 = fs.readFileSync(ARTIFACTS.oddSpecJson, "utf8");

  const p4 = loadPrompt("04_codegen_nestjs.md")
    .replace("{{ODD_SPEC_JSON}}", oddSpecText2)
    .replace("{{ARCH_PLAN_JSON}}", archPlanText);

  const manifest = await ollamaGenerateJson(MODELS.qwen, p4);

  writeFile(ARTIFACTS.codegenManifest, JSON.stringify(manifest, null, 2));
  writeFilesFromManifest(manifest);

  console.log("  -> apps/generated/*");
  console.log("  -> artifacts/plans/codegen_manifest.json");
}

main().catch((err) => {
  console.error("Erro fatal:", err);
  process.exit(1);
});

// ---------------- Helpers ----------------
function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--input") out.input = argv[++i];
  }
  return out;
}

function ensureDirs(dirs) {
  for (const d of dirs) fs.mkdirSync(d, { recursive: true });
}

function loadPrompt(name) {
  const p = path.join(ROOT, "tools", "runner", "prompts", name);
  return fs.readFileSync(p, "utf8");
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, "utf8");
}

/**
 * Extrai YAML puro da resposta do modelo.
 * - Remove fences ```yaml ... ```
 * - Remove fences ``` ... ```
 * - Remove texto antes da primeira "root key" do YAML
 */
function extractYaml(text) {
  const t = String(text ?? "").trim();

  // Caso 1: veio dentro de ```yaml ... ```
  const fencedYaml = t.match(/```ya?ml\s*([\s\S]*?)\s*```/i);
  if (fencedYaml?.[1]) return fencedYaml[1].trim();

  // Caso 2: veio dentro de ``` ... ``` (sem linguagem)
  const fencedAny = t.match(/```\s*([\s\S]*?)\s*```/);
  if (fencedAny?.[1]) return fencedAny[1].trim();

  // Caso 3: corta a partir da primeira linha que parece "key: value"
  const lines = t.split(/\r?\n/);
  const startIdx = lines.findIndex(
    (l) => /^[a-zA-Z0-9_-]+\s*:\s*.*$/.test(l) && !l.trim().startsWith("#")
  );
  if (startIdx >= 0) return lines.slice(startIdx).join("\n").trim();

  return t;
}

function safeParseYaml(yamlText) {
  try {
    return YAML.parse(yamlText);
  } catch (e) {
    const out = path.join(ARTIFACTS.logsDir, "yaml_parse_error.txt");
    writeFile(out, String(e));
    // também salva o yaml que falhou para debug
    const dump = path.join(ARTIFACTS.logsDir, "yaml_failed_dump.yaml");
    writeFile(dump, yamlText);
    throw new Error(`YAML inválido. Detalhes em ${out} (dump em ${dump})`);
  }
}

function loadEventMappingV3(inputPath) {
  const abs = path.isAbsolute(inputPath) ? inputPath : path.join(ROOT, inputPath);
  if (!fs.existsSync(abs)) throw new Error(`Arquivo não encontrado: ${abs}`);

  const wb = xlsx.readFile(abs);
  const sheetName = wb.SheetNames[0];
  const sheet = wb.Sheets[sheetName];

  const rowsRaw = xlsx.utils.sheet_to_json(sheet, { defval: "" });
  const rows = rowsRaw.map((r, idx) => {
    try {
      return V3RowSchema.parse(r);
    } catch (e) {
      throw new Error(`Linha ${idx + 2} inválida (header na linha 1): ${e}`);
    }
  });

  // Ordenação forte por "Ordem" (aceita "3.1" ou "3,1")
  const parseOrder = (v) => {
    if (typeof v === "number") return v;
    const s = String(v).trim().replace(",", ".");
    const n = Number(s);
    return Number.isFinite(n) ? n : 999999;
  };
  rows.sort((a, b) => parseOrder(a.Ordem) - parseOrder(b.Ordem));

  return { kind: "event_mapping_v3", sheet: sheetName, rows };
}

async function assertOllamaUp() {
  const r = await fetch(`${OLLAMA_URL}/api/tags`);
  if (!r.ok) throw new Error(`Ollama não respondeu em ${OLLAMA_URL}. Está rodando?`);
}

async function ollamaGenerateText(model, prompt) {
  const body = {
    model,
    prompt,
    stream: false,
    options: {
      temperature: 0.2,
    },
  };

  const r = await fetch(`${OLLAMA_URL}/api/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!r.ok) throw new Error(`Falha no Ollama generate: ${r.status} ${await r.text()}`);
  const data = await r.json();
  return String(data.response ?? "").trim();
}

async function ollamaGenerateJson(model, prompt) {
  const wrapped = [
    "Responda SOMENTE com JSON válido. Sem markdown. Sem texto extra.",
    prompt,
  ].join("\n\n");

  const txt = await ollamaGenerateText(model, wrapped);

  // 1) tenta parse direto
  const direct = tryParseJson(txt);
  if (direct.ok) return direct.value;

  // 2) tenta extrair de ```json ... ``` ou ``` ... ```
  const extractedFromFence = extractJsonFromFence(txt);
  const fenceParsed = tryParseJson(extractedFromFence);
  if (fenceParsed.ok) return fenceParsed.value;

  // 3) tenta extrair primeiro objeto/array JSON do texto
  const extracted = extractFirstJsonObjectOrArray(txt);
  const extractedParsed = tryParseJson(extracted);
  if (extractedParsed.ok) return extractedParsed.value;

  // Dump para debug
  const out = path.join(ARTIFACTS.logsDir, `json_parse_error_${Date.now()}.txt`);
  writeFile(out, txt);

  const out2 = path.join(ARTIFACTS.logsDir, `json_parse_candidate_${Date.now()}.txt`);
  writeFile(out2, extractedFromFence || extracted || "");

  throw new Error(`Modelo não retornou JSON válido. Dump em ${out}`);
}

function tryParseJson(s) {
  try {
    return { ok: true, value: JSON.parse(String(s).trim()) };
  } catch {
    return { ok: false };
  }
}

function extractJsonFromFence(text) {
  const t = String(text ?? "").trim();

  // ```json ... ```
  const fencedJson = t.match(/```json\s*([\s\S]*?)\s*```/i);
  if (fencedJson?.[1]) return fencedJson[1].trim();

  // ``` ... ```
  const fencedAny = t.match(/```\s*([\s\S]*?)\s*```/);
  if (fencedAny?.[1]) return fencedAny[1].trim();

  return t;
}

/**
 * Extrai o primeiro objeto {...} ou array [...] que pareça JSON, respeitando aspas/escape.
 * Funciona bem para respostas com texto antes/depois.
 */
function extractFirstJsonObjectOrArray(text) {
  const s = String(text ?? "");
  const start = s.search(/[\{\[]/);
  if (start < 0) return s.trim();

  let inString = false;
  let escape = false;
  const stack = [];
  let end = -1;

  for (let i = start; i < s.length; i++) {
    const ch = s[i];

    if (inString) {
      if (escape) {
        escape = false;
      } else if (ch === "\\") {
        escape = true;
      } else if (ch === '"') {
        inString = false;
      }
      continue;
    }

    if (ch === '"') {
      inString = true;
      continue;
    }

    if (ch === "{" || ch === "[") {
      stack.push(ch);
      continue;
    }

    if (ch === "}" || ch === "]") {
      const last = stack.pop();
      if (!last) continue;
      if ((last === "{" && ch !== "}") || (last === "[" && ch !== "]")) continue;
      if (stack.length === 0) {
        end = i + 1;
        break;
      }
    }
  }

  if (end > 0) return s.slice(start, end).trim();
  return s.slice(start).trim();
}

function ensureParentDir(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function writeFilesFromManifest(manifest) {
  if (!manifest?.files || !Array.isArray(manifest.files)) {
    throw new Error("Manifest inválido: esperado { files: [{path, content}...] }");
  }

  for (const f of manifest.files) {
    if (!f.path || typeof f.path !== "string") throw new Error("Manifest inválido: file.path");
    if (typeof f.content !== "string") throw new Error(`Manifest inválido: content não é string (${f.path})`);

    const abs = path.isAbsolute(f.path) ? f.path : path.join(ROOT, f.path);
    ensureParentDir(abs);
    fs.writeFileSync(abs, f.content, "utf8");
  }
}