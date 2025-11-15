# Orquestração de Containers: Padrões e Práticas para Ambientes Resilientes

Instalação e configuração do K8S e publicação do primeiro serviço

## Cluster 

Exemplos e material foi construído com utilização em Env Dev do [Colima](https://github.com/abiosoft/colima) e [Lens](https://github.com/lensapp/lens)

### Instalação e configuração do Colima no Mac 

[TODO]: ajustar para o Linux

```sh
brew install colima

# Sobe o Colima com o docker+k3s embutido, veja na doc caso queira Containerd
colima start --kubernetes --cpu 4 --memory 12
# Isso cria o cluster k3s automaticamente e ajusta o kubeconfig em ~/.kube/config.

# Verificar a utilização
kubectl get nodes
# NAME     STATUS   ROLES                  AGE   VERSION
# colima   Ready    control-plane,master   21s   v1.33.4+k3s1

# Quando precisar parar
colima stop
```

### Instalação e configuração do Lens no Mac

[TODO]: ajustar para o Linux

```
brew install --cask lens
# Depois abre o app:
# 	•	Applications > Lens (ou busca por “Lens” no Spotlight)
# Pra testar se está tudo ok
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
```


## Certificados e autoassinador
Iniciar com a preparação para o uso de SSL no cluster

### Cert-Manager 

Instalação do CertManager: "Automatically provision and manage TLS certificates in Kubernetes".

```sh
kubectl create ns cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

kubectl get pods -n cert-manager
```

```sh
kubectl apply -f cluster-issuer-selfsigned.yaml
```

### Registry

Criação de um Container Registry local no K8S.

Caso precise limpar antes
```sh
kubectl delete all --all -n registry --ignore-not-found
kubectl delete namespace registry --ignore-not-found
kubectl get all -A | grep registry || echo "✅ Nada restando"
```

Criar o Registry 
```sh
kubectl create namespace registry
kubectl apply -f registry-deployment.yaml
kubectl get pods -n registry
```


Adicionar o endereço local ao hosts
```sh
sudo sh -c 'echo "\n127.0.0.1  registry.local" >> /etc/hosts' 
# Conferir se deu tudo certo, a última linha deve ser a entrada
cat /etc/hosts
```

Criar o certificado

```sh
kubectl apply -f registry-cert.yaml
# Conferir se o secret foi criado
kubectl get secret registry-tls -n registry
```

Aplica o Ingress
```sh
kubectl apply -f registry-ingress.yaml
# Verificar o acesso
curl -vk https://registry.local/v2/_catalog
```


## Criação da O11y

### Instalar o nginx para fazer o roteamento do cluster para acesso externo

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
```

### Instalação do Datadog
```sh
# Adiciona o repo do DD
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Cria namespace para facilitar o isolamento e controle
kubectl create namespace observability
# Insere a chave de API como secret no cluster
kubectl create secret generic datadog-api-key \
  --from-literal api-key=0ed2c8926f568187347ba622a5e57424 \
  -n observability
# Instala o agente no namespace
helm install datadog-agent -f datadog-values.yaml datadog/datadog -n observability

# verificar a secret
kubectl get secret datadog-api-key -n observability -o yaml
# Verifica o valor da secret
kubectl get secret datadog-api-key -n observability -o jsonpath='{.data.api-key}' | base64 --decode

# destroy caso necessario
helm uninstall datadog-agent -n observability
kubectl delete secret datadog-api-key -n observability
kubectl delete ns observability --ignore-not-found=true
```


## Build das aplicações


### Aplicação

```sh
kubectl create secret generic webshop-api-secrets \
  --from-literal=DD_API_KEY=$DD_API_KEY$ \
  --from-literal=DD_AGENT_HOST=localhost \
  --from-literal=DD_TRACE_AGENT_PORT=8126 \
  --from-literal=DD_ENV=development \
  --from-literal=DD_SERVICE=webshop-api \
  --from-literal=DD_VERSION=1.0.0

kubectl create configmap webshop-api-config \
  --from-literal=MAGENTO_URL=http://localhost:8080 \
  --from-literal=ORDER_MGMT_API_URL=http://localhost:4010/order/group


kubectl get secrets webshop-api-secrets -o yaml
kubectl get configmap webshop-api-config -o yaml

DD_API_KEY=0ed2c8926f568187347ba622a5e57424 docker compose up -d

docker build -t webshop-api:1.0.0 .


docker run -d -it --rm -p 3000:3000 \
  -e MAGENTO_URL=http://localhost:8080 \
  -e ORDER_MGMT_API_URL=http://localhost:4010/order/group \
  -e DD_API_KEY=0ed2c8926f568187347ba622a5e57424 \
  -e DD_AGENT_HOST=localhost \
  -e DD_TRACE_AGENT_PORT=8126 \
  -e DD_ENV=development \
  -e DD_SERVICE=webshop-api \
  -e DD_VERSION=1.0.0 \
 webshop-api:1.0.2

 curl -i -X POST "http://localhost:3000/group-buying" \          
  -H "Content-Type: application/json" \
  -d '{"userId":"trigger-500","items":[{"productId":"p1","qty":2}]}'

# verificar as imagens
docker images | grep webshop-api

kubectl apply -f webshop-api-deployment.yaml
kubectl get pods
kubectl describe pod webshop-api-9ccbbf86f-5ztxm

kubectl delete deployment webshop-api
kubectl apply -f webshop-api-deployment.yaml

```


IMAGE_NAME="webshop-api"
IMAGE_TAG="1.0.2"
REGISTRY_NAMESPACE="registry"
REGISTRY_SERVICE="registry"
REGISTRY_PORT="5000"
REGISTRY_IMAGE="registry:2"

kubectl port-forward -n registry pod/registry 5000:5000 >/tmp/registry-forward.log 2>&1 &