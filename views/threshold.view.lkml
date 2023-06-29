view: threshold_0 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0" }
}}}

view: threshold_1 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.1" }
    }}}

view: threshold_2 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.2" }
    }}}

view: threshold_3 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.3" }
    }}}

view: threshold_4 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.4" }
    }}}

view: threshold_5 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.5" }
    }}}

view: threshold_6 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.6" }
    }}}

view: threshold_7 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.7" }
    }}}

view: threshold_8 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.8" }
    }}}

view: threshold_9 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "0.9" }
    }}}

view: threshold_10 { derived_table: { explore_source: radiology_predictions {
      column: model_name {} column: threshold_dim {} column: precision {} column: recall {} column: f1_score {}
      filters: { field: radiology_predictions.threshold value: "1" }
    }}}

view: threshold {
  derived_table: {
    sql:
                SELECT * FROM ${threshold_0.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_1.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_2.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_3.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_4.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_5.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_6.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_7.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_8.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_9.SQL_TABLE_NAME}
      UNION ALL SELECT * FROM ${threshold_10.SQL_TABLE_NAME}
    ;;
  }


  dimension: pk {
    primary_key: yes
    type: string
    sql: ${model_name} || '-' || ${threshold} ;;
  }
  dimension: model_name {
    link: {
      label: "Deep Dive - {{ value }}"
      url: "https://experiment-demoexpo.dev.looker.com/dashboards/40?Threshold=0.3&Model+Name={{ value }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.looker.com"
    }
  }
  dimension: threshold {
    type: number
    sql: ${TABLE}.threshold_dim ;;
    value_format_name: percent_0
  }
  dimension: precision_dim {
    type: number
    sql: ${TABLE}.precision ;;
  }
  dimension: recall_dim {
    type: number
    sql: ${TABLE}.recall ;;
  }
  dimension: f1_score_dim {
    type: number
    sql: ${TABLE}.f1_score ;;
  }

  parameter: metric_selector {
    type: unquoted
    default_value: "f1_score"
    allowed_value: {label: "F1 Score" value: "f1_score"}
    allowed_value: {label: "Precision" value: "precision"}
    allowed_value: {label: "Recall" value: "recall"}
  }

  measure: dynamic_metric {
    type: number
    sql:
      {% if    metric_selector._parameter_value == 'f1_score' %} ${f1_score}
      {% elsif metric_selector._parameter_value == 'precision' %} ${precision}
      {% elsif metric_selector._parameter_value == 'recall' %} ${recall}
      {% else %} ${f1_score}
      {% endif %};;
    value_format_name: percent_1
  }

  measure: avg_threshold {
    label: "Threshold"
    type: average
    sql: ${threshold} ;;
    value_format_name: percent_0
  }
  measure: precision {
    type: average
    sql: ${precision_dim} ;;
    value_format_name: percent_0
  }
  measure: recall {
    type: average
    sql: ${recall_dim} ;;
    value_format_name: percent_0
  }
  measure: recall_viz {
    type: average
    sql: ${recall_dim} ;;
    value_format_name: percent_0
    html: {{rendered_value}} (Threshold: {{ avg_threshold._rendered_value }}) ;;
  }
  measure: f1_score {
    type: average
    sql: ${f1_score_dim} ;;
    value_format_name: percent_0
  }
}
