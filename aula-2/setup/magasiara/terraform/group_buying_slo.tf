resource "datadog_service_level_objective" "group_buying_visibility" {
  name        = "Criação e Visibilidade de Grupo de Compra Coletiva"
  type        = "metric"
  description = <<EOT
Como comprador,
Quero iniciar um grupo de compra,
Para aproveitar descontos progressivos baseados em volume.

Dado que o produto é elegível para compra coletiva,
E que as regras exigem ao menos 10 compradores com pedidos pagos dentro de 7 dias,
Quando eu criar o primeiro carrinho de compra para esse produto,
Então um novo grupo de compra é criado,
E o grupo é anunciado,
E passa a ser exibido em todas as buscas relacionadas a esse produto.

Este SLO mede a razão entre tentativas de iniciar um grupo de compra (evento `group_buying.shopcart.buybox.added`)
e os casos bem-sucedidos onde um grupo é efetivamente criado e visível (evento `group_buying.available_group.status.view{group:created}`),
em um intervalo de até 5 minutos.
EOT

  query {
    # numerator   = "sum:group_buying.shopcart.buybox.added{group:created}.as_count()"
    # denominator = "sum:group_buying.available_group.status.view{group:created}.as_count()"
    numerator = "sum:group_buying.available_group.status.view{group:created}.as_count()"
    denominator = "sum:group_buying.shopcart.buybox.added{group:created}.as_count()"
  }
  # The numerator query defines the sum of the good events
  # sum:httpservice.hits{code:2xx} + sum:httpservice.hits{code:4xx}
  # The denominator query defines the sum of all events
  # sum:httpservice.hits{!code:3xx}


  thresholds {
    timeframe = "7d"
    target  = 99.9
    warning = 99.95
  }

}