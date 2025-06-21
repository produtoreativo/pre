import { test, expect } from '@playwright/test';
import axios from 'axios';
import { setTimeout } from 'timers/promises';
import * as dotenv from 'dotenv';
dotenv.config();

const NEW_RELIC_API_KEY = process.env.NEW_RELIC_API_KEY!;
const NEW_RELIC_ACCOUNT_ID = process.env.NEW_RELIC_ACCOUNT_ID!;

test('trace no frontend deve ser vinculado ao erro no New Relic', async ({ page }) => {
  let traceparentHeader: string | null = null;

  console.log('Iniciando teste de trace no frontend...');
  console.log('Certifique-se de que o New Relic está configurado corretamente no frontend.');
  console.log('NEW_RELIC_API_KEY: ', NEW_RELIC_API_KEY);
  console.log('NEW_RELIC_ACCOUNT_ID: ', NEW_RELIC_ACCOUNT_ID);

  // Intercepta todas as requisições para capturar header 'traceparent' ou 'newrelic'
  page.on('request', (request) => {
    //console.log('Request URL:', request.url());
    if (request.url().includes('/products')) {
      console.log('Requisição de busca disparada:', request.url());
    }

    const headers = request.headers();
    if (headers['traceparent']) {
      traceparentHeader = headers['traceparent'];
      console.log('Header traceparent capturado:', traceparentHeader);
    } else if (headers['newrelic']) {
      traceparentHeader = headers['newrelic'];
      console.log('Header newrelic capturado:', traceparentHeader);
    }
  });

  // Navega para o frontend
  await page.goto('http://localhost:5173');

  // Interage com o campo search para disparar a requisição com trace
  // await page.fill('[data-testid="search-input"] input', 'coca');
  const requestPromise = page.waitForRequest((req) =>
    req.url().startsWith('http://localhost:3000/products') && req.method() === 'GET'
  );

  // await page.evaluate(() => {
  //   const input = document.querySelector('[data-testid=\"search-input\"] input');
  //   const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')?.set;
  //   setter?.call(input, 'glenio');
  //   input.dispatchEvent(new Event('input', { bubbles: true }));
  // });
// Foco e digitação real no input
  await page.focus('[data-testid="search-input"] input');
  await page.keyboard.type('glenio');

  const request = await requestPromise;
  console.log('Requisição capturada:', request.url());

  // Aguarda um tempo para requisição e erro ocorrerem
  // await page.waitForTimeout(3000);
    // Aguarda a requisição AJAX disparada pela digitação
  // await page.waitForRequest((req) =>
  //   req.url().startsWith('http://localhost:3000/products') && req.method() === 'GET'
  // );

  expect(traceparentHeader).not.toBeNull();

  // Extrai o traceId do header W3C traceparent (ex: "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01")
  // O traceId é o segundo segmento (posição 1)
  const traceId = traceparentHeader!.split('-')[1];
  console.log('Trace ID extraído do header:', traceId);

  console.log('Esperando ingestão do trace_id no New Relic...');
  await setTimeout(20000);

  // const nrql = `SELECT * FROM Log WHERE trace.id = '${traceId}' SINCE 50 minutes ago`;

  const nrql = `SELECT * FROM TransactionError where traceId = '${traceId}' SINCE 30 minutes ago`;

  const response = await axios.post(
    'https://api.newrelic.com/graphql',
    {
      query: `{
        actor {
          account(id: ${NEW_RELIC_ACCOUNT_ID}) {
            nrql(query: "${nrql}") {
              results
            }
          }
        }
      }`,
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'API-Key': NEW_RELIC_API_KEY,
      },
    }
  );

  console.log('Resposta do New Relic:', JSON.stringify( response.data.data?.actor?.account ) );

  const logs = response.data?.data?.actor?.account?.nrql?.results || [];
  expect(logs.length).toBeGreaterThan(0);
  console.log('Erro do frontend corretamente vinculado ao trace:', traceId);
});