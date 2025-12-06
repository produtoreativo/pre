#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------
# CONFIGURAÇÕES DO KEYCLOAK E SERVIÇO
# --------------------------------------------
KONG_ADMIN="http://localhost:8001"
KEYCLOAK_URL="http://keycloak:8080"
REALM="magasiara"
CLIENT_ID="webshop-api"
CLIENT_SECRET="kOFqFAYBIqnbnm4jGT4FaWcwlBfkae3J"

SERVICE_NAME="webshop-api"
# SERVICE_URL="http://webshop-api:3000"
# ROUTE_PATH="/keycloack-test"

# echo "🔎 Criando serviço no Kong..."
# curl -s -X POST $KONG_ADMIN/services \
#   --data "name=$SERVICE_NAME" \
#   --data "url=$SERVICE_URL" | jq .


# echo "🔎 Criando rota /webshop no Kong..."
# curl -s -X POST $KONG_ADMIN/services/$SERVICE_NAME/routes \
#   --data "name=${SERVICE_NAME}-route" \
#   --data "paths[]=$ROUTE_PATH" | jq .


echo "🔐 Configurando plugin OIDCify no modo bearer_only..."
curl -s -X POST "${KONG_ADMIN}/services/${SERVICE_NAME}/plugins" \
  --data "name=oidcify" \
  --data "config.issuer=${KEYCLOAK_URL}/realms/${REALM}" \
  --data "config.redirect_uri=http://localhost:8000/_oauth" \
  --data "config.consumer_name=webshop-api" \
  --data "config.client_id=${CLIENT_ID}" \
  --data "config.client_secret=${CLIENT_SECRET}" \
  --data "config.bearer_jwt_allowed_auds[]=${CLIENT_ID}" \
  --data "config.bearer_jwt_allowed_auds[]=account" \
  --data "config.bearer_jwt_allowed_algs[]=RS256" \
  --data "config.use_userinfo=false" \
  --data "config.use_pkce=false" \
  --data "config.redirect_unauthenticated=false" \
  --data "config.static_provider_config.authorization_endpoint=${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/auth" \
  --data "config.static_provider_config.token_endpoint=${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/token" \
  --data "config.static_provider_config.userinfo_endpoint=${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/userinfo" \
  --data "config.static_provider_config.jwks_uri=${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/certs" \
  --data "config.static_provider_config.id_token_signing_alg_values_supported[]=RS256" \
  --data "config.id_token_claims_header=X-User-Claims" \
  | jq .

echo "✅ Plugin OIDCify configurado com sucesso!"
echo ""
echo "Kong agora:"
echo "  ✔ valida o token localmente via JWKS"
echo "  ✔ exige Authorization: Bearer <token>"
echo "  ✔ retorna 401 JSON se o token for inválido ou expirado"
echo ""
echo "Teste assim:"
echo ""
echo "1) Requisição com token inválido:"
echo "   curl -i http://localhost:8000/keycloack-test"
echo ""
echo "2) Requisição com token válido:"
echo "   curl -i -H \"Authorization: Bearer <TOKEN>\" http://localhost:8000/keycloack-test"
echo ""