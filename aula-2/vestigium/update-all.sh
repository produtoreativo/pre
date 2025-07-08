#!/bin/bash

set -e

BASE_DIR=./produtos
REPOS=(
  "webshop"
  "webshop-api"
  "search-api"
  "order-mngt-api"
)
BRANCH=vestigium-dd

echo "Iniciando update dos repositórios..."
cd "$BASE_DIR"

for REPO in "${REPOS[@]}"; do
  echo "Fazendo checkout da branch $BRANCH em $REPO..."
  cd "$REPO"
  git fetch
  git pull --rebase origin $BRANCH || echo "Branch '$BRANCH' não encontrada em $REPO"
  
  if [[ "$REPO" == "search-api" ]]; then
    cd nest-search-api
    npm install
    cd ..
  else
    npm install
  fi

  cd ..
done

echo "Update completo."