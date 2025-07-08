resource "datadog_dashboard" "group_closure_dashboard" {
  title       = "Grupo de Compra - Encerramento por Prazo"
  layout_type = "ordered"
  description = "Observabilidade do encerramento autom\u00e1tico de grupos por expira\u00e7\u00e3o do prazo m\u00e1ximo."

  widget {
    timeseries_definition {
      title = "Taxa de Adesão no Encerramento"
      show_legend = true

      request {
        q            = "avg:group_buying.group.adherence_rate{*}.rollup(avg, 60)"
        display_type = "line"
        style {
          palette    = "cool"
          line_type  = "solid"
          line_width = "normal"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Grupos Encerrados sem Aderência Suficiente"
      request {
        q            = "sum:group_buying.group.closed.pending_approval.count{*}.rollup(sum, 60)"
        display_type = "bars"
        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title     = "Tempo Médio até Encerramento"
      show_legend = true
      request {
        q = "avg:group_buying.group.time_to_close{*}"
        display_type = "line"
        style {
          palette = "dog_classic"
        }
      }
      yaxis {
        label = "Tempo (segundos)"
        scale = "linear"
        include_zero = true
      }
    }
  }
}