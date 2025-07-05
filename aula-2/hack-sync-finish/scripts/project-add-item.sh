#!/bin/bash

set -e  # Encerra se qualquer comando falhar

# if [ -z "$1" ]; then
#   echo "Uso: git hack <issue_number>"
#   exit 1
# fi
GITHUB_PROJECT_NUMBER="$1"
OWNER=$2
REPO=$3
ISSUE=$4

echo "📦 Project Number extraído e salvo: $GITHUB_PROJECT_NUMBER"
echo "📦 Project Owner: $OWNER"
echo "📦 Project Repo: $REPO"

echo "➕ Adicionando issue #$ISSUE ao projeto #$GITHUB_PROJECT_NUMBER..."
gh project item-add "$GITHUB_PROJECT_NUMBER" --url "https://github.com/$OWNER/$REPO/issues/$ISSUE"
