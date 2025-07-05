# Observabilidade (O11Y) em primeiro lugar

Aula 2 inicia modelagem com DataDog, siga os passos seguintes para validar a estrutura.

## DataDog

Precisa gerar uma API Key e uma Application Key em dois menus diferentes que encontra a partir do icone do usuário no canto inferior esquerdo em:

![API Keys](./assets/aula2-datadog-1.png)

## Terraform

Estrutura inicial para criação dos nossos artefatos de Infra as a Code utilizando o Terraform para gerar toda a observabilidade do plano de Confiabilidade.

Antes de executar, crie um arquivo em /aula-2/setup/magasiara/terraform/terraform.tfvars

Com o conteúdo:
```sh
datadog_api_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
datadog_app_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
datadog_site    = "datadoghq.com"
```

### Criar a Dashboard com os comandos

```sh
cd aula-2/setup/magasiara/terraform
terraform init
terraform plan
terraform apply
```

### Ingestão dos dados para testar a Dashboard com

```sh
export DD_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export DD_APP_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

chmod +x send_group_metrics.sh
./send_group_metrics.sh
```


## Repositórios utilizados

Agregador de Confiabilidade:  
https://github.com/produtoreativo/webshop 

Repositórios dos serviços:  
https://github.com/produtoreativo/webshop  
https://github.com/produtoreativo/webshop-api  
https://github.com/produtoreativo/search-api  
https://github.com/produtoreativo/order-mngt-api  
