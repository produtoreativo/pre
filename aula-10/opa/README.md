# Configurações do Plugin OPA

Para testar se um rego está válido

```sh
docker exec -it kong sh
curl -X POST http://opa:8181/v1/data/authz/allow \
  -d '{"input":{"method":"GET"}}'
```