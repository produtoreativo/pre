#!/usr/bin/env bash
set -e

IMAGE_NAME="webshop-api"
IMAGE_TAG="1.0.3"
REGISTRY_NAMESPACE="registry"
REGISTRY_SERVICE="registry"
REGISTRY_PORT="5000"
REGISTRY_IMAGE="registry:2"

echo " [1/6] Garantindo que o namespace '$REGISTRY_NAMESPACE' existe..."
kubectl get ns $REGISTRY_NAMESPACE >/dev/null 2>&1 || kubectl create ns $REGISTRY_NAMESPACE

echo " [2/6] Criando registry dentro do cluster (caso não exista)..."
if ! kubectl get svc -n $REGISTRY_NAMESPACE | grep -q $REGISTRY_SERVICE; then
  kubectl run $REGISTRY_SERVICE \
    --image=$REGISTRY_IMAGE \
    --port=$REGISTRY_PORT \
    -n $REGISTRY_NAMESPACE
  kubectl expose pod $REGISTRY_SERVICE \
    --type=ClusterIP \
    --port=$REGISTRY_PORT \
    -n $REGISTRY_NAMESPACE \
    --name=$REGISTRY_SERVICE
else
  echo " Registry já existe."
fi

echo " [3/6] Aguardando registry iniciar..."
kubectl wait --for=condition=ready pod/$REGISTRY_SERVICE -n $REGISTRY_NAMESPACE --timeout=60s

echo " [4/6] Criando port-forward do registry localmente..."
# Mata qualquer port-forward antigo antes de recriar
lsof -ti tcp:$REGISTRY_PORT | xargs kill -9 >/dev/null 2>&1 || true
kubectl port-forward -n $REGISTRY_NAMESPACE pod/$REGISTRY_SERVICE $REGISTRY_PORT:$REGISTRY_PORT >/tmp/registry-forward.log 2>&1 &
sleep 5

echo " Testando conexão com o registry..."
for i in {1..10}; do
  if curl -fs http://localhost:$REGISTRY_PORT/v2/ >/dev/null; then
    echo " Conexão com o registry OK."
    break
  fi
  echo " Tentando novamente ($i/10)..."
  sleep 3
done

if ! curl -fs http://localhost:$REGISTRY_PORT/v2/ >/dev/null; then
  echo " Falha ao conectar no registry local em localhost:$REGISTRY_PORT"
  exit 1
fi

echo " [5/6] Publicando imagem local no registry interno..."

./push-tar-to-registry.sh webshop-api_1.1.3.tar 127.0.0.1:5000 webshop-api $IMAGE_TAG
#docker tag ${IMAGE_NAME}:${IMAGE_TAG} localhost:${REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG}
#docker push localhost:${REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG}

echo " [6/6] Testando acesso via cluster..."
kubectl run test-${IMAGE_NAME} --rm -it \
  --image=localhost:${REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG} \
  --restart=Never -- bash || true

echo " Concluído! Imagem publicada em: localhost:${REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG}"