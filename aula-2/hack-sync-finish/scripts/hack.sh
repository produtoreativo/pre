#!/bin/bash

set -e  # Encerra se qualquer comando falhar

if [ -z "$1" ]; then
  echo "Uso: git hack <issue_number>"
  exit 1
fi

ISSUE="$1"
BRANCH="feat/#$ISSUE"

echo "🔒 Stashing alterações..."
git stash

echo "📦 Atualizando dev..."
git checkout dev
git pull --rebase origin dev

echo "🌱 Criando nova branch: $BRANCH"
git checkout -b "$BRANCH" dev

echo "🔍 Status atual:"
git status

echo "🔍 Push para o servidor remoto:"
git push -u origin "$BRANCH"

# 📝 Atualizando a issue no GitHub
echo "💬 Comentando na issue #$ISSUE"
gh issue comment "$ISSUE" --body "🔨 Começando desenvolvimento na branch \`$BRANCH\`" || echo "⚠️ Falha ao comentar. Ignorando..."

