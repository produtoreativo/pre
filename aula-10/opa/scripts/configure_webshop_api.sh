#!/usr/bin/env bash
set -euo pipefail

KONG_ADMIN="http://localhost:8001"
SERVICE_NAME="webshop-api"
SERVICE_URL="http://webshop-api:3000"
ROUTE_HOST="webshop.local"

OPA_URL="http://opa:8181"

echo "===> Criando serviço '${SERVICE_NAME}'..."
curl -s -X PUT "${KONG_ADMIN}/services/${SERVICE_NAME}" \
  --data "url=${SERVICE_URL}"

echo "===> Criando rota para '${SERVICE_NAME}'..."
curl -s -X POST "${KONG_ADMIN}/services/${SERVICE_NAME}/routes" \
  --data "hosts[]=${ROUTE_HOST}" \
  --data "paths[]=/"

echo "===> Aplicando plugin KongOPAfy..."
curl -s -X POST "${KONG_ADMIN}/services/${SERVICE_NAME}/plugins" \
  --data "name=kong-opafy" \
  --data "config.opa_url=${OPA_URL}"

echo "===> Finalizado!"
echo "Plugin KongOPAfy ativado para o serviço ${SERVICE_NAME}"