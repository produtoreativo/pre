# Observabilidade (O11Y) em primeiro lugar

## Criar uma conta no NewRelic

Os primeiros exemplos utilizam o [NewRelic](https://newrelic.com/) como ferramenta de Observabilidade. Crie uma conta e ative o primeiro API Key em:
![API Keys](./assets/aula1-newrelic-1.png)

Guarde as informações: Account ID, Value (é a License API Key). Sugestão, crie com name de trace-integration.

## Iniciado o teste

1. Execute o setup para baixar todos os projetos.  

Pré-requisitos até o momento: git, nodejs.  

Precisa de ambiente nodejs instalado para rodar os exemplos. Eu utilizo o [nvm](https://github.com/nvm-sh/nvm) como gerenciador de versões para executar o ambiente. (Para quem conhece nodejs, é bem antigo e existem outras opções mais jovens, mas sou velho, gosto de velharias).  
Versão do [nvm para Windows](https://github.com/coreybutler/nvm-windows).  
Quem é aluno da formação, recebeu um Voucher para utilizar ferramentas da Jetbrains, mas é indiferente de IDE.

Verifique se o ambiente está ok:

```sh
git version
#git version 2.47.0

node -v
# v22.7.0
```

Execute a sequencia de comandos a seguir para executar o exemplo depois que tiver seu ambiente nodejs funcionando.

Baixe o projeto em: 

```sh
git clone git@github.com:produtoreativo/pre.git
```

Entre na pasta vestigium e siga os próximos passos:


```sh
# Entre na raiz da pasta vestigium
cd pre/aula-1/vestigium/
```

Clone o arquivo .env-model e renomeie o clone para .env, substitua as variáveis com os dados do NewRelic que voce guardou.

Execute o setup para carregar os repositorios:  
```sh
# Na raiz da pasta vestigium
chmod +x setup.sh
./setup.sh
```

Este script baixa todos os projetos para dentro de uma pasta nomeada como "produtos", caso não crie a pasta automatico, execute o:

```sh
# Na raiz da pasta vestigium
mkdir produtos
```

O projeto que é uma Web Application, webshop, precisa de uma configuração específica do Elasticsearch:  
 Vai no Menu BROWSER -> Add Data [canto superior direito da aba].   
Pesquisa por "browser monitoring'.  
Escolhe a opção "Place a JavaScript snippet in frontend code".
Preencha as informações e no final salve esse snippet:

![Browser Config](./assets/aula1-newrelic-2.png)

Clone o arquivo aula-1/vestigium/produtos/webshop/src/store/newrelic/options-example.ts para aula-1/vestigium/produtos/webshop/src/store/newrelic/options.ts e substitua os valores pelos dados do Snippet que voce acabou de salvar.

1.1. Quando precisar, atualize os repositorios para pegar a versão mais recente.  
```sh
chmod +x update-all.sh
./update-all.sh
```

2. Execute os repos para funcionarem em paralelo.  
```sh
chmod +x start-all.sh
./start-all.sh
```

3. Abra no navegador para verificar se está tudo ok.  
http://localhost:5173/

4. Execute os testes para verificar o funcionamento do NewRelic

Em outra aba do terminal, garanta que o ambiente de testes está funcional, execute:

```sh
# Na raiz da pasta vestigium
npm install
````

Então execute os testes em:

```sh
npm run test:e2e
```

As vezes quando executa pela primeira vez depois de algum tempo, o NewRelic demora um pouco mais a responder e dá erro no teste.  
Procure o trecho a seguir no arquivo [./aula-1/vestigium/tests/e2e/trace.integration.spec.ts](./aula-1/vestigium/tests/e2e/trace.integration.spec.ts) e incremente um pouco mais o tempo em milisegundos:

```js
await setTimeout(20000);
```

## Criar uma Dashboard com NRQL
	1.	Acesse o New Relic One → Dashboards → Create a dashboard.
	2.	Dê um nome como Erros - Consulta de Produto.
	3.	Clique em “Add a chart”, selecione “NRQL query” e use:

```
SELECT count(*) FROM TransactionError 
WHERE request.uri LIKE '%/products%' OR transactionName LIKE '%/products%' 
SINCE 30 minutes ago TIMESERIES
```


## Repositórios utilizados

Agregador de Confiabilidade:  
https://github.com/produtoreativo/webshop 

Repositórios dos serviços:  
https://github.com/produtoreativo/webshop  
https://github.com/produtoreativo/webshop-api  
https://github.com/produtoreativo/search-api  
https://github.com/produtoreativo/order-mngt-api  
