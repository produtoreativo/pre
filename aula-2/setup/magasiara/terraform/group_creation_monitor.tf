resource "datadog_monitor" "low_group_creation_alert" {
  name               = "🚨 Baixa criação de grupos (últimos 5 min)"
  type               = "metric alert"
  escalation_message = "Escalonar após 30 minutos se o número continuar baixo."
    message = <<-MSG
🚨 *Alerta de Criação de Grupos* 🚨  
Nos últimos 5 minutos, o número de grupos criados caiu abaixo de 10.  

Verifique o funcionamento da jornada de compra coletiva.

🔔 @webhook-discord-groupbuying
MSG

  query = "sum(last_5m):group_buying.available_group.status.view{group:created} < 10"

  monitor_thresholds {
    warning  = 20
    critical = 10
  }

  include_tags = true

  tags = ["env:test", "service:group_buying"]
}
