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

BASE_DIR=./produtos
REPOS=(
  "webshop"
  "webshop-api"
  "search-api"
  "order-mngt-api"
)

echo "Iniciando checkout dos repositórios..."
cd "$BASE_DIR"

for REPO in "${REPOS[@]}"; do
  echo "Fazendo checkout da branch vestigium em $REPO..."
  cd "$REPO"
  git checkout vestigium
  cd ..
done


echo "Usando license_key: $NEW_RELIC_API_KEY"
echo "Iniciando todos os serviços com New Relic em modo watch..."

concurrently -k -n "webshop,webshop-api,search-api,order-mngt-api" -c "blue,green,magenta,cyan" \
  "NEW_RELIC_API_KEY=$NEW_RELIC_API_KEY npm --prefix $PROJETOS_DIR/webshop run start:watch:newrelic" \
  "NEW_RELIC_API_KEY=$NEW_RELIC_API_KEY npm --prefix $PROJETOS_DIR/webshop-api run start:watch:newrelic" \
  "NEW_RELIC_API_KEY=$NEW_RELIC_API_KEY npm --prefix $PROJETOS_DIR/search-api/nest-search-api run start:watch:newrelic" \
  "NEW_RELIC_API_KEY=$NEW_RELIC_API_KEY npm --prefix $PROJETOS_DIR/order-mngt-api run start:watch:newrelic"