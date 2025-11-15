#!/bin/bash
set -e  # para parar se algo der errado

source ~/.nvm/nvm.sh

echo "Migrando configuração do ESLint"
yarn dlx @eslint/migrate-config .eslintrc.js

# echo "Executando o lint"
# yarn lint

# curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
# Na minha maquina que é mac eu isntalo com
# brew install act

echo "Guardando o diretório atual"
ORIGINAL_DIR=$(pwd)
echo "$ORIGINAL_DIR"
echo "Clonando o repositório de preparação do pipeline"
cd ~/produtos/pre/aula-3-4-5
cp -r ./setup/ $ORIGINAL_DIR/

echo "Executando o pipeline"
cd "$ORIGINAL_DIR"
# act workflow_dispatch -j validate -P ubuntu-latest=node:22-bullseye --container-architecture linux/amd64

# act workflow_dispatch -j validate \
#   -P ubuntu-latest=node:22-bullseye \
#   --container-architecture linux/amd64 \
#   -s SONAR_TOKEN=sqp_dfdd1cf03329c7fd9da9ec57734187231e543b55

npx ts-node -r tsconfig-paths/register scripts/swagger.ts