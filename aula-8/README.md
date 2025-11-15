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


## Criação da O11y


### Instalar o nginx para fazer o roteamento do cluster para acesso externo

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
```


### Namespaces
```sh
kubectl create ns monitoring   # Prometheus + Grafana + OTel
kubectl create ns tracing      # Tempo
kubectl create ns cert-manager # TLS opcional
```

### Cert-Manager (opcional, TLS automático)
```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

### Instalar Prometheus Operator (kube-prometheus-stack)
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prom-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f prom-stack-values.yaml
# quando precisar atualizar
helm upgrade prom-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f prom-stack-values.yaml
```

### Loki (logs) + OpenTelemetry Collector

Clean caso necessário
```sh
helm uninstall loki -n logging || true
kubectl delete ingress -n logging --all || true
kubectl delete svc -n logging --all || true
kubectl delete deploy,sts,daemonset -n logging --all || true
kubectl delete pvc -n logging --all --ignore-not-found=true
kubectl delete ns logging --ignore-not-found=true
```

```sh
# adiciona o repositorio loki
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
# cria o namespace 
kubectl create ns logging
# instala o loki
helm install loki grafana/loki -n logging -f loki-values.yaml
# quando precisar atualizar
helm upgrade loki grafana/loki -n logging -f loki-values.yaml

sudo sh -c 'echo "\n127.0.0.1 loki.localhost" >> /etc/hosts' 
```

Habilitar acesso externo manualmente
```sh
kubectl port-forward --namespace logging svc/loki-gateway 3100:80 &
kubectl port-forward -n logging svc/loki 3100:3100
```

Testar a ingestão
```sh
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:3100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"
```
Consultar
```sh
curl "http://loki.localhost:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .

# ou só o resultado
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result


curl "http://loki.localhost/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result


curl "http://loki.localhost/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .
```



Url para usar no grafana http://loki-gateway.logging.svc.cluster.local/


### Instalar o Tempo

```sh
helm install tempo grafana/tempo -n tracing --values - <<EOF
mode: "all-in-one"
ingester:
  persistence:
    enabled: true
    size: 10Gi
EOF
```

### Grafana

Instalar o grafana

```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
cat > grafana-values.yaml <<EOF
adminUser: admin
adminPassword: strong-password
persistence:
  enabled: true
  storageClassName: "local-path"
  accessModes: ["ReadWriteOnce"]
  size: 10Gi
service:
  type: NodePort
  ports:
    - port: 80
      targetPort: 3000
      nodePort: 3010
ingress:
  enabled: true
  ingressClassName: nginx
  hosts:
    - grafana.localhost
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  tls:
    - hosts:
      - grafana.localhost
      secretName: grafana-tls
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prom-stack-kube-prometheus-prometheus.monitoring.svc:9090
        access: proxy
      - name: Loki
        type: loki
        url: http://loki.logging.svc:3100
      - name: Tempo
        type: tempo
        url: http://tempo.tracing.svc:3200

EOF

helm install grafana grafana/grafana -n monitoring -f grafana-values.yaml
```



Configura
```sh
# verificar a senha
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# strong-password

# adicionar o endereço do grafana para acessar localmente
sudo sh -c 'echo "\n127.0.0.1 grafana.localhost" >> /etc/hosts' 

# 
# kubectl port-forward -n monitoring svc/grafana 3000:80 &
```


## Build das aplicações


```sh
# Adiciona o repo do DD
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Cria namespace para facilitar o isolamento e controle
kubectl create namespace observability
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