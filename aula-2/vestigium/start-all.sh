#!/bin/bash

set -e

ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Arquivo .env não encontrado. Abortando."
  exit 1
fi

# Caminho base dos projetos NestJS
PROJETOS_DIR=~/produtos
BRANCH=vestigium-dd
BASE_DIR=$(pwd)/produtos
REPOS=(
  "webshop"
  "webshop-api"
  "search-api"
  "order-mngt-api"
)

# echo "Iniciando checkout dos repositórios..."
# cd "$BASE_DIR"

# for REPO in "${REPOS[@]}"; do
#   echo "Fazendo checkout da branch $BRANCH em $REPO..."
#   cd "$REPO"
#   git checkout $BRANCH
#   cd ..
# done

echo "Diretório atual: $BASE_DIR"

echo "Usando license_key: $DD_API_KEY"
echo "Iniciando todos os serviços com DataDog em modo watch..."

DD_VARS="DD_API_KEY=$DD_API_KEY DD_AGENT_HOST=localhost DD_TRACE_AGENT_PORT=8126 DD_ENV=development DD_VERSION=1.0.0"
echo "Variáveis de ambiente do DataDog configuradas: $DD_VARS"

concurrently -k -n "webshop,webshop-api,search-api,order-mngt-api" -c "blue,green,magenta,cyan" \
  "$DD_VARS DD_SERVICE=webshop npm --prefix $BASE_DIR/webshop run dev" \
  "$DD_VARS DD_SERVICE=webshop-api npm --prefix $BASE_DIR/webshop-api run start:dev" \
  "$DD_VARS DD_SERVICE=search-api ELASTICSEARCH_URL=http://localhost:9200 npm --prefix $BASE_DIR/search-api/nest-search-api run start:dev" \
  "$DD_VARS DD_SERVICE=order-mngt-api npm --prefix $BASE_DIR/order-mngt-api run start:dev"
