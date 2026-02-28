# ODD Greenfield

Workflow de estudos para geração de projeto completo Greenfield a partir de um Event Sourcing

## Configurações

Instalação e configuração no MacBookPro M1 com 32G de RAM
```sh
brew install ollama
brew services start ollama #sobe o ollama serve
ollama pull qwen2.5-coder:14b
ollama pull llama3.1:8b
ollama -v
# ollama version is 0.17.4
```

## Execução

Foi utilizado nodejs 22 nesse repo.  

```sh
npm run odd:run
```


## Racional ProdOps pra AI

Mentalidade sempre de inverter Pessoas executando apoiadas por Software para Software executando sendo apoiado por pessoas.   
Se há um Toil, este deve ser substituindo com o modelo possível.  
Quando construir agentes, pensa no corpo humano, a complexidade para construir celulas, tecidos, orgãos, comunicação entre eles.  
Context demais gera exaustão, contexto de menos halucina, ambos deixam menos preciso.  
Use a teoria de Maturidade ProdOps para construir o raciocinio de cada agente por Capability.  
