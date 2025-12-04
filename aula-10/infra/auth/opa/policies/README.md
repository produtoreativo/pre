

Playground para testar suas regras

https://play.openpolicyagent.org/



https://developer.konghq.com/plugins/opa/


```sh
brew install opa # instalação local para validação

opa check authz.rego # testar a sintaxe, se estiver ok não retorna nada

opa eval -i input.json -d authz.rego "data.authz.allow"
```