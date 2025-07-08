#!/bin/bash

set -e

ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Arquivo .env não encontrado. Abortando."
  exit 1
fi

BRANCH=vestigium-dd
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

  echo "Fazendo checkout da branch $BRANCH em $REPO..."
  cd "$REPO"
  git fetch
  git checkout $BRANCH || echo "Branch '$BRANCH' não encontrada em $REPO"

  if [[ "$REPO" == "search-api" ]]; then
    cd nest-search-api
    npm install
    cd ..
  else
    npm install
  fi

  cd ..
done

echo "Setup completo."