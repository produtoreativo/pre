#!/bin/bash

set -e

ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Arquivo .env não encontrado. Abortando."
  exit 1
fi

BASE_DIR=./produtos
REPOS=(
  "webshop"
  "webshop-api"
  "search-api"
  "order-mngt-api"
)
GITHUB_BASE_URL="https://github.com/produtoreativo"

echo "Iniciando setup dos repositórios..."

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

for REPO in "${REPOS[@]}"; do
  if [ ! -d "$REPO" ]; then
    echo "Clonando $REPO..."
    git clone "$GITHUB_BASE_URL/$REPO.git"
  else
    echo "Repositório $REPO já existe. Pulando clone..."
  fi

  echo "Fazendo checkout da branch vestigium em $REPO..."
  cd "$REPO"
  git fetch
  git checkout vestigium || echo "Branch 'vestigium' não encontrada em $REPO"
  npm install

  echo "Criando arquivo newrelic.js para $REPO..."
  cat > newrelic.js <<EOF
'use strict';
exports.config = {
  app_name: '$REPO',
  license_key: '$NEW_RELIC_API_KEY',
  distributed_tracing: {
    enabled: true,
  },
  logging: {
    level: 'trace',
  },
  allow_all_headers: true,
  attributes: {
    exclude: [
      'request.headers.cookie',
      'request.headers.authorization',
      'request.headers.proxyAuthorization',
      'request.headers.setCookie*',
      'request.headers.x*',
      'response.headers.cookie',
      'response.headers.authorization',
      'response.headers.proxyAuthorization',
      'response.headers.setCookie*',
      'response.headers.x*',
    ],
  },
};
EOF

  cd ..
done

echo "Setup completo."