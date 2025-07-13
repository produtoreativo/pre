resource "datadog_dashboard" "group_buying_dashboard" {
  title       = "🛒 Group Buying - Formação"
  description = "Monitoramento de falhas e progresso no fluxo de abertura e adesão da compra em grupo"
  layout_type = "ordered"

  widget {
    group_definition {
      title       = "🔴 Falhas na Formação dos Grupos"
      layout_type = "ordered"

      widget {
        query_value_definition {
          title = "Ofertas não indexadas"
          request {
            q = "sum:group_buying.catalog.offer.view.failure{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "white_on_red"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 0
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Falhas ao Adicionar ao Carrinho"
          request {
            q = "sum:group_buying.shopcart.buybox.added.failure{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "red_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 4
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Falhas ao Formar Grupo"
          request {
            q = "sum:group_buying.available_group.status.failure{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_red"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 8
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Tentativa Criação"
          request {
            q = "sum:group_buying.shopcart.buybox.added.failure{group:created}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "red_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 4
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Tentativa de Adesão"
          request {
            q = "sum:group_buying.shopcart.buybox.added.failure{group:adhesion}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "red_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 6
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Durante Criação ao Grupo"
          request {
            q = "sum:group_buying.available_group.status.failure{group:created}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_red"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 8
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Durante Adesão ao Grupo"
          request {
            q = "sum:group_buying.available_group.status.failure{group:adhesion}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_red"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 10
          y      = 0
          width  = 2
          height = 2
        }
      }

    }
  }

  widget {
    group_definition {
      title      = "🔴 Falhas no Fluxo de Formação"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "Falhas na Vitrine"
          request {
            q = "sum:group_buying.catalog.offer.view.failure{*}.as_count()"
            display_type = "line"
            style {
              palette = "red"
            }
          }
        }
        widget_layout {
          x = "0"
          y = "0"
          width = "4"
          height = "2"
        }
      }

      widget {
        timeseries_definition {
          title = "Falhas ao Adicionar ao Carrinho"
          request {
            q = "sum:group_buying.shopcart.buybox.added.failure{*}.as_count()"
            display_type = "line"
            style {
              palette = "red"
            }
          }
        }
        widget_layout {
          x = "4"
          y = "0"
          width = "4"
          height = "2"
        }
      }

      widget {
        timeseries_definition {
          title = "Falhas ao Formar Grupo"
          request {
            q = "sum:group_buying.available_group.status.failure{*}.as_count()"
            display_type = "line"
            style {
              palette = "red"
            }
          }
        }
        widget_layout {
          x = "8"
          y = "0"
          width = "4"
          height = "2"
        }
      }
    }
  }

  widget {
    group_definition {
      title      = "🟢 Formação de Grupos"
      layout_type = "ordered"

      widget {
        query_value_definition {
          title = "Ofertas indexadas"
          request {
            q = "sum:group_buying.catalog.offer.view{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = "<"
              value      = 100
              palette    = "white_on_yellow"
            }
            conditional_formats {
              comparator = ">="
              value      = 100
              palette    = "white_on_green"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 0
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Adicionados ao Carrinho"
          request {
            q = "sum:group_buying.shopcart.buybox.added{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = "<"
              value      = 10
              palette    = "yellow_on_white"
            }
            conditional_formats {
              comparator = ">="
              value      = 10
              palette    = "green_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 4
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Eventos de Formação de Grupos"
          request {
            q = "sum:group_buying.available_group.status.view{*}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_green"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 8
          y      = 0
          width  = 4
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Durante Criação do Grupo"
          request {
            q = "sum:group_buying.shopcart.buybox.added{group:created}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "green_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 4
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Durante Adesão ao Grupo"
          request {
            q = "sum:group_buying.shopcart.buybox.added{group:adhesion}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "green_on_white"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 6
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Criação de Grupo"
          request {
            q = "sum:group_buying.available_group.status.view{group:created}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_green"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 8
          y      = 0
          width  = 2
          height = 2
        }
      }

      widget {
        query_value_definition {
          title = "Adesão ao Grupo"
          request {
            q = "sum:group_buying.available_group.status.view{group:adhesion}.rollup(sum, 3600)"
            conditional_formats {
              comparator = ">"
              value      = 0
              palette    = "black_on_light_green"
            }
          }
          autoscale = true
        }
        widget_layout {
          x      = 10
          y      = 0
          width  = 2
          height = 2
        }
      }

    }
  }

  widget {
    group_definition {
      title      = "🟢 Sucessos no Fluxo"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "Ofertas Visualizadas"
          request {
            q = "sum:group_buying.catalog.offer.view{*}.as_count()"
            display_type = "line"
          }
        }
        widget_layout {
          x = "0"
          y = "0"
          width = "4"
          height = "2"
        }
      }

      widget {
        timeseries_definition {
          title = "Produtos no Carrinho"
          request {
            q = "sum:group_buying.shopcart.buybox.added{*}"
            display_type = "line"
          }
        }
        widget_layout {
          x = "4"
          y = "0"
          width = "4"
          height = "2"
        }
      }

      widget {
        timeseries_definition {
          title = "Grupos Criados"
          request {
            q = "sum:group_buying.available_group.status.view{*}"
            display_type = "line"
          }
        }
        widget_layout {
          x = "8"
          y = "0"
          width = "4"
          height = "2"
        }
      }


    }
  }
}