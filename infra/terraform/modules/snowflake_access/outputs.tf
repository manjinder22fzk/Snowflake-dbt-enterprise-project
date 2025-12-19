output "access_roles" {
  value = {
    raw_load            = snowflake_account_role.ar_raw_load.name
    raw_read            = snowflake_account_role.ar_raw_read.name
    analytics_transform = snowflake_account_role.ar_analytics_transform.name
    gold_read           = snowflake_account_role.ar_gold_read.name
  }
}
