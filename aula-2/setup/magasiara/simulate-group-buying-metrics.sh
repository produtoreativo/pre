#!/bin/bash

echo "🚀 Iniciando simulação de métricas de compra coletiva para Datadog..."
DATADOG_API_URL="https://api.datadoghq.com/api/v1/series"
source .env
echo $DD_API_KEY
echo $DD_APP_KEY
echo $DATADOG_API_URL

echo "🔑 Verificando chaves de API..."
if [[ -z "$DD_API_KEY" || -z "$DD_APP_KEY" ]]; then
  echo "❌ Erro: Defina DD_API_KEY e DD_APP_KEY antes de rodar o script."
  exit 1
fi

# Função para gerar número aleatório
random() {
  shuf -i $1-$2 -n 1
}

while true; do
  echo "⏱️ Enviando métricas de simulação para Datadog..."

  timestamp=$(date +%s)
  GROUP_ID=$(uuidgen)
  GROUP_ID2=$(uuidgen)

  payload=$(cat <<EOF
{
  "series": [
    { "metric": "group_buying.catalog.offer.view.failure", "points": [[$timestamp, $(random 0 10)]], "type": "count", "tags": ["env:test"], "host": "group-buying-bash" },
    { "metric": "group_buying.shopcart.buybox.added.failure", "points": [[$timestamp, $(random 0 5)]], "type": "count", "tags": ["env:test", "group:created"], "host": "group-buying-bash" },
    { "metric": "group_buying.shopcart.buybox.added.failure", "points": [[$timestamp, $(random 0 5)]], "type": "count", "tags": ["env:test", "group:adhesion"], "host": "group-buying-bash" },
    { "metric": "group_buying.available_group.status.failure", "points": [[$timestamp, $(random 0 1)]], "type": "count", "tags": ["env:test", "group:created"], "host": "group-buying-bash" },
    { "metric": "group_buying.available_group.status.failure", "points": [[$timestamp, $(random 0 1)]], "type": "count", "tags": ["env:test", "group:adhesion"], "host": "group-buying-bash" },
  
    { "metric": "group_buying.catalog.offer.view", "points": [[$timestamp, $(random 10 100)]], "type": "count", "tags": ["env:test"], "host": "group-buying-bash" },
    { "metric": "group_buying.shopcart.buybox.added", "points": [[$timestamp, $(random 5 15)]], "type": "gauge", "tags": ["env:test", "group:created"], "host": "group-buying-bash" },
    { "metric": "group_buying.shopcart.buybox.added", "points": [[$timestamp, $(random 5 35)]], "type": "gauge", "tags": ["env:test", "group:adhesion"], "host": "group-buying-bash" },
    { "metric": "group_buying.available_group.status.view", "points": [[$timestamp, 1]], "type": "gauge", "tags": ["env:test", "group:created", "group_id:$GROUP_ID"], "host": "group-buying-bash" },
    { "metric": "group_buying.available_group.status.view", "points": [[$timestamp, 1]], "type": "gauge", "tags": ["env:test", "group:adhesion", "group_id:$GROUP_ID"], "host": "group-buying-bash" },
    { "metric": "group_buying.available_group.status.view", "points": [[$timestamp, 1]], "type": "gauge", "tags": ["env:test", "group:created", "group_id:$GROUP_ID2"], "host": "group-buying-bash" }
  ]
}
EOF
)

  curl -s -X POST "$DATADOG_API_URL" \
    -H "Content-Type: application/json" \
    -H "DD-API-KEY: $DD_API_KEY" \
    -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
    -d "$payload"
  echo "✅ Métricas enviadas com sucesso!"

  sleep 15
done