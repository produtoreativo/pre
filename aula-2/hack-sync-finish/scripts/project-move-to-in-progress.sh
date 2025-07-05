#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Uso: $0 <issue_number> <project_number> <project_id>"
  exit 1
fi

ISSUE_NUMBER="$1"
PROJECT_NUMBER="$2"
GITHUB_PROJECT_ID="$3"
OWNER="produtoreativo"
TARGET_STATUS="In Progress"

echo "🔍 Buscando item da issue #$ISSUE_NUMBER no projeto $PROJECT_NUMBER..."

ITEM_ID=$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json | \
  jq -r --argjson issue "$ISSUE_NUMBER" '.items[] | select(.content.number == $issue) | .id')

if [ -z "$ITEM_ID" ]; then
  echo "❌ Issue #$ISSUE_NUMBER não encontrada no projeto $PROJECT_NUMBER."
  exit 1
fi

echo "✅ Item ID encontrado: $ITEM_ID"

echo "🔍 Buscando campo 'Status'..."
STATUS_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json | \
  jq -r '.fields[] | select(.name == "Status") | .id')

if [ -z "$STATUS_FIELD_ID" ]; then
  echo "❌ Campo 'Status' não encontrado."
  exit 1
fi

echo "✅ Campo 'Status' ID: $STATUS_FIELD_ID"

echo "🔍 Buscando valor '$TARGET_STATUS'..."
STATUS_VALUE_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json | \
  jq -r --arg TARGET "$TARGET_STATUS" '.fields[] | select(.name == "Status") | .options[] | select(.name == $TARGET) | .id')

if [ -z "$STATUS_VALUE_ID" ]; then
  echo "❌ Valor '$TARGET_STATUS' não encontrado no campo 'Status'."
  exit 1
fi

echo "🚀 Atualizando status da issue #$ISSUE_NUMBER para '$TARGET_STATUS'..."

gh project item-edit \
  --id "$ITEM_ID" \
  --project-id "$GITHUB_PROJECT_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --single-select-option-id "$STATUS_VALUE_ID"

echo "✅ Status atualizado com sucesso!"