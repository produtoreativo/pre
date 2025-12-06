# Aula 10: Auth e API Management

## Setup

### Kong com o plugin de OpenID embutido

Gerar imagem local no seu Docker

```sh
cd aula-10/infra/kong-custom 
docker build -t kong-oidcify .
```

### Criar a infraestrutura

Crie uma rede específica no Docker para compartilhar com o ambiente de dev

```sh
docker network create magasiara
```

Docker compose da infraestrutura, já cria Kong, Keycloak e OPA.

```sh
cd aula-10/infra/auth
docker compose up -d
```

### Criar Realm no Keyckoak

Configurar as variáveis, por padrão o terraform.tfvars está com o usuário admin de instalação default.

```sh
#1. Ajuste `terraform.tfvars` (nunca commite secrets)
cd aula-10/keycloak
terraform init
terraform plan
terraform apply -auto-approve
```

### Criar um usuário para testar e validar o Login

Criar um usuário para validar:
```sh
cd aula-10/keycloak/scrips
chmod +x create-user.sh 
./create-user.sh 

# ➡️ GROUP_ID=e2e84fe3-7237-4373-a612-b554e71615c9
# ✔️ Usuário adicionado ao grupo 'customers'!
# 🎉 Usuário criado/atualizado com sucesso!

# 📌 Credenciais:
#     username: cmilfont
#     email: cmilfont@gmail.com
#     password: testes55
```

Testar o Login:
```sh
cd aula-10/keycloak/scrips
chmod +x login-create-token.sh
./login-create-token.sh

# 🔐 Iniciando login do usuário 'cmilfont' no realm 'magasiara'...
# Secret do client 'webshop-api' obtido: eqfWAMQRHTwv61e7B61eiD6FR7IIIiXp
# → Autenticando usuário no Keycloak...
# ✅ Login realizado com sucesso!

# Access Token:
# eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJuV3hlYUplT0JiVWN4dkhMMGxvS2t0Nl9KNjRzczQtMUk5TG1IUzExb2ZVIn0.eyJleHAiOjE3NjUwNDg1MDksImlhdCI6MTc2NTA0NjcwOSwianRpIjoiY2IyZWUwMDctNmQwMy00OTM4LWFlZTEtYzI2YzVkMzZkYTBjIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrOjgwODAvcmVhbG1zL21hZ2FzaWFyYSIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiJiNjY3MDJkOC00Y2YxLTQ1ZmUtYjNhNS0wZTA3YjI2ZWRlZTEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ3ZWJzaG9wLWFwaSIsInNpZCI6ImY2MjZhMWE5LTNkOWMtNGRjZS04NWQwLTI1N2ZhNTg2ZDY2NyIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiY3VzdG9tZXI6cmVhZCIsImRlZmF1bHQtcm9sZXMtbWFnYXNpYXJhIiwib2ZmbGluZV9hY2Nlc3MiLCJjdXN0b21lcjpvcmRlcjpjcmVhdGUiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJjbWlsZm9udCIsImVtYWlsIjoiY21pbGZvbnRAZ21haWwuY29tIn0.AG0HEXZG6R10_NifrCjaL4tlwUcrQEECTcZDdGaCfmrDF1LDQRxewIdr2RqRkz0Ha6-wodzSIa9jvrLIlHy6qTc9-f5JH3C6rwLbNPpjeRfg8Uv1vtzRM7Vpzt7j1HO8IRQcT2Y0du4CNSS63XngpNQ-o4eQ-6uXivjYat3S27HkvYpf-4myeAJNykbrj2ZWU6G0mH3IUHlwWRdWxCgBppJjrayKLn6piOthAzz0Guyr8AAFB1cHTQiHqpob64EFyCrH3CpBlh8fmPsLf4biGY3OUnIeanyIos9mFrsHd3zUcgAUh2g3MinchDSpUmefW2qlp7NiZGCufUUOyj5rrg

# Refresh Token:
# eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwOWRkNGFiZi1kMDg0LTRlNTUtYjQwYy1lYzAzM2U2NWQ1NzcifQ.eyJleHAiOjE3NjUwNDg1MDksImlhdCI6MTc2NTA0NjcwOSwianRpIjoiMmNhYmQ0ODMtOTMyZi00OGU3LWE3NzAtYTlmNzFmYzA1N2Q3IiwiaXNzIjoiaHR0cDovL2tleWNsb2FrOjgwODAvcmVhbG1zL21hZ2FzaWFyYSIsImF1ZCI6Imh0dHA6Ly9rZXljbG9hazo4MDgwL3JlYWxtcy9tYWdhc2lhcmEiLCJzdWIiOiJiNjY3MDJkOC00Y2YxLTQ1ZmUtYjNhNS0wZTA3YjI2ZWRlZTEiLCJ0eXAiOiJSZWZyZXNoIiwiYXpwIjoid2Vic2hvcC1hcGkiLCJzaWQiOiJmNjI2YTFhOS0zZDljLTRkY2UtODVkMC0yNTdmYTU4NmQ2NjciLCJzY29wZSI6InJvbGVzIGVtYWlsIGJhc2ljIGFjciB3ZWItb3JpZ2lucyBwcm9maWxlIn0.6vF1wdbqoEELq0nliPustbu4L6TxTQULxfKoblxHyL8ID-dmWqhEDDhL62CMsgFd-Telm-LZk2Cm7gIIGxW-4g

# Expira em: 1800s

# → Dica: exporte o token para usar em chamadas:
#  TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJuV3hlYUplT0JiVWN4dkhMMGxvS2t0Nl9KNjRzczQtMUk5TG1IUzExb2ZVIn0.eyJleHAiOjE3NjUwNDg1MDksImlhdCI6MTc2NTA0NjcwOSwianRpIjoiY2IyZWUwMDctNmQwMy00OTM4LWFlZTEtYzI2YzVkMzZkYTBjIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrOjgwODAvcmVhbG1zL21hZ2FzaWFyYSIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiJiNjY3MDJkOC00Y2YxLTQ1ZmUtYjNhNS0wZTA3YjI2ZWRlZTEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ3ZWJzaG9wLWFwaSIsInNpZCI6ImY2MjZhMWE5LTNkOWMtNGRjZS04NWQwLTI1N2ZhNTg2ZDY2NyIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiY3VzdG9tZXI6cmVhZCIsImRlZmF1bHQtcm9sZXMtbWFnYXNpYXJhIiwib2ZmbGluZV9hY2Nlc3MiLCJjdXN0b21lcjpvcmRlcjpjcmVhdGUiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJjbWlsZm9udCIsImVtYWlsIjoiY21pbGZvbnRAZ21haWwuY29tIn0.AG0HEXZG6R10_NifrCjaL4tlwUcrQEECTcZDdGaCfmrDF1LDQRxewIdr2RqRkz0Ha6-wodzSIa9jvrLIlHy6qTc9-f5JH3C6rwLbNPpjeRfg8Uv1vtzRM7Vpzt7j1HO8IRQcT2Y0du4CNSS63XngpNQ-o4eQ-6uXivjYat3S27HkvYpf-4myeAJNykbrj2ZWU6G0mH3IUHlwWRdWxCgBppJjrayKLn6piOthAzz0Guyr8AAFB1cHTQiHqpob64EFyCrH3CpBlh8fmPsLf4biGY3OUnIeanyIos9mFrsHd3zUcgAUh2g3MinchDSpUmefW2qlp7NiZGCufUUOyj5rrg"

```
