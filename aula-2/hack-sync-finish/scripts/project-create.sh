#!/bin/bash

TITLE="$1"
echo "Project $TITLE"

# Troque o owner pra sua conta e repo para o seu repositorio de estudos
# Cria o projeto e salva a resposta JSON
json=$(gh project create --title $TITLE --owner produtoreativo --format json)

#json='{"number":17,"url":"https://github.com/orgs/produtoreativo/projects/17","shortDescription":"","public":false,"closed":false,"title":"Sprint Junho","id":"PVT_kwDOAT1J1c4A8Rtj","readme":"","items":{"totalCount":0},"fields":{"totalCount":10},"owner":{"type":"Organization","login":"produtoreativo"}}'

# Extrai o ID do projeto com jq
project_id=$(echo "$json" | jq -r '.id')
project_number=$(echo "$json" | jq -r '.number')

# Armazena em uma variável de ambiente (por exemplo, para o restante do script)
export GITHUB_PROJECT_ID="$project_id"
export GITHUB_PROJECT_NUMBER="$project_number"

echo "GITHUB_PROJECT_ID=$GITHUB_PROJECT_ID" > .env.project
echo "GITHUB_PROJECT_NUMBER=$GITHUB_PROJECT_NUMBER" >> .env.project
# Quando precisar, executar o source .env.project

# Exibe para conferência
echo "📦 Project ID extraído e salvo: $GITHUB_PROJECT_ID"
echo "📦 Project Number extraído e salvo: $GITHUB_PROJECT_NUMBER"