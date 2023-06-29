view: radiology_predictions {
  sql_table_name: `hca-sandbox-aaron-argolis.radiology.model_predictions_clean_table`
    ;;

#######################
### Original Dimensions
#######################

  dimension: pk {
    primary_key: yes
    type: string
    sql: ${model_name} || '-' || ${file_name} ;;
  }

  dimension: file_name {
    type: string
    sql: ${TABLE}.file_name ;;
  }

  dimension: gcs_bucket {
    type: string
    sql: ${TABLE}.gcs_bucket ;;
  }

  dimension: label {
    type: number
    sql: ${TABLE}.label ;;
  }

  dimension: model_name {
    type: string
    sql: ${TABLE}.model_name ;;
  }

  dimension: prediction {
    type: number
    sql: ${TABLE}.prediction ;;
  }

  dimension: slice_id {
    type: string
    sql: ${TABLE}.slice_id ;;
  }

  dimension: study_id {
    type: string
    sql: ${TABLE}.study_id ;;
  }

#######################
### Derived Dimensions
#######################

  parameter: threshold {
    type: number
    default_value: "0.3"
    allowed_value: { label: "0%" value: "0" }
    allowed_value: { label: "10%" value: "0.1" }
    allowed_value: { label: "20%" value: "0.2" }
    allowed_value: { label: "30%" value: "0.3" }
    allowed_value: { label: "40%" value: "0.4" }
    allowed_value: { label: "50%" value: "0.5" }
    allowed_value: { label: "60%" value: "0.6" }
    allowed_value: { label: "70%" value: "0.7" }
    allowed_value: { label: "80%" value: "0.8" }
    allowed_value: { label: "90%" value: "0.9" }
    allowed_value: { label: "100%" value: "1" }
  }

  dimension: threshold_dim {
    type: number
    sql: {% parameter threshold %} ;;
  }

  dimension: is_tp {
    type: yesno
    sql: ${label} = 1 and ${prediction} >= {% parameter threshold %} ;;
  }

  dimension: is_fp {
    type: yesno
    sql: ${label} = 0 and ${prediction} >= {% parameter threshold %} ;;
  }

  dimension: is_fn {
    type: yesno
    sql: ${label} = 1 and ${prediction} < {% parameter threshold %} ;;
  }

  dimension: is_tn {
    type: yesno
    sql: ${label} = 0 and ${prediction} < {% parameter threshold %} ;;
  }

  dimension: status {
    type: string
    sql:
      case
        when ${is_tp} then 'TP'
        when ${is_fp} then 'FP'
        when ${is_fn} then 'FN'
        when ${is_tn} then 'TN'
        else 'Unknown'
      end
        ;;
  }

  dimension: prediction_roc_auc {
    description: "Create many buckets - for ROC/AUC curve"
    type: number
    sql: round(round(${prediction}/2,2)*2,2) ;;
  }


#######################
### Measures
#######################

  measure: count {
    type: count
    drill_fields: [file_name]
  }

  measure: tp {
    group_label: "#"
    label: "# TP"
    type: count
    filters: [is_tp: "Yes"]
  }

  measure: fp {
    group_label: "#"
    label: "# FP"
    type: count
    filters: [is_fp: "Yes"]
  }

  measure: fn {
    group_label: "#"
    label: "# FN"
    type: count
    filters: [is_fn: "Yes"]
  }

  measure: tn {
    group_label: "#"
    label: "# TN"
    type: count
    filters: [is_tn: "Yes"]
  }

  measure: tp_total {
    group_label: "%"
    label: "TP (% of Total)"
    type: number
    sql: ${tp} / nullif(${count},0) ;;
    value_format_name: percent_0
  }

  measure: fp_total {
    group_label: "%"
    label: "FP (% of Total)"
    type: number
    sql: ${fp} / nullif(${count},0) ;;
    value_format_name: percent_0
  }

  measure: fn_total {
    group_label: "%"
    label: "FN (% of Total)"
    type: number
    sql: ${fn} / nullif(${count},0) ;;
    value_format_name: percent_0
  }

  measure: tn_total {
    group_label: "%"
    label: "TN (% of Total)"
    type: number
    sql: ${tn} / nullif(${count},0) ;;
    value_format_name: percent_0
  }

  measure: precision {
    group_label: "Adv"
    label: "Precision"
    type: number
    sql: ${tp} / nullif((${tp} + ${fp}),0) ;;
    value_format_name: percent_0
  }

  measure: recall {
    group_label: "Adv"
    label: "Recall"
    type: number
    sql: ${tp} / nullif((${tp} + ${fn}),0) ;;
    value_format_name: percent_0
  }

  measure: tpr {
    group_label: "Adv"
    label: "TP %"
    type: number
    sql: ${recall} ;;
    value_format_name: percent_0
  }

  measure: fpr {
    group_label: "Adv"
    label: "FP %"
    type: number
    sql: ${fp} / nullif((${fp} + ${tn}),0) ;;
    value_format_name: percent_0
  }

  measure: f1_score {
    group_label: "Adv"
    type: number
    sql: 2 * ${tp} / nullif(((2 * ${tp}) + ${fp} + ${fn}),0) ;;
    value_format_name: percent_0
  }

  measure: count_distinct_prediction_roc_auc {
    type: count_distinct
    sql: ${prediction_roc_auc} ;;
  }

  measure: running_total {
    type: running_total
    sql: ${count_distinct_prediction_roc_auc} ;;
  }
}
