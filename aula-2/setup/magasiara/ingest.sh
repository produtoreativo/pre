#!/bin/bash

# Verifica variáveis de ambiente
if [[ -z "$DD_API_KEY" || -z "$DD_APP_KEY" ]]; then
  echo "❌ Erro: Defina DD_API_KEY e DD_APP_KEY antes de rodar o script."
  exit 1
fi

# Configurações
DATADOG_API="https://api.datadoghq.com/api/v1/series"
TIMESTAMP=$(date +%s)

# Simulação de métricas para dashboard
payload=$(cat <<EOF
{
  "series": [
    {
      "metric": "group_buying.group.closed.pending_approval.count",
      "points": [[$TIMESTAMP, 3]],
      "type": "count",
      "tags": ["context:group_buying", "domain:closing", "feature:group", "env:dev"],
      "host": "simulated-ingestor"
    },
    {
      "metric": "group_buying.group.adherence_rate",
      "points": [[$TIMESTAMP, 0.64]],
      "type": "gauge",
      "tags": ["context:group_buying", "domain:closing", "env:dev"],
      "host": "simulated-ingestor"
    },
    {
      "metric": "group_buying.group.closed.total.count",
      "points": [[$TIMESTAMP, 12]],
      "type": "count",
      "tags": ["context:group_buying", "domain:closing", "env:dev"],
      "host": "simulated-ingestor"
    },
    {
      "metric": "group_buying.group.adhesion.new.count",
      "points": [[$TIMESTAMP, 5]],
      "type": "count",
      "tags": ["context:group_buying", "domain:adhesion", "env:dev"],
      "host": "simulated-ingestor"
    }
  ]
}
EOF
)

# Envia para o Datadog
curl -s -X POST "$DATADOG_API" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -d "$payload"

echo "✅ Métricas enviadas para o Datadog com timestamp $TIMESTAMP"