#!/bin/bash

set -e

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
  cd ..
done

echo "Setup completo."