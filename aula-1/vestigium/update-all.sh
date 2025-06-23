#!/bin/bash

set -e

BASE_DIR=./produtos
REPOS=(
  "webshop"
  "webshop-api"
  "search-api"
  "order-mngt-api"
)

echo "Iniciando update dos repositórios..."
cd "$BASE_DIR"

for REPO in "${REPOS[@]}"; do
  echo "Fazendo checkout da branch vestigium em $REPO..."
  cd "$REPO"
  git fetch
  git pull --rebase origin vestigium || echo "Branch 'vestigium' não encontrada em $REPO"
  npm install

  cd ..
done

echo "Update completo."