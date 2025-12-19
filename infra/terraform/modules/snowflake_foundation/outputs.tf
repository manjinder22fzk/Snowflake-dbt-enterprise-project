output "databases" {
  value = var.databases
}

output "warehouses" {
  value = var.warehouses
}

output "roles" {
  value = {
    platform_admin = snowflake_account_role.platform_admin.name
    ingest         = snowflake_account_role.ingest.name
    transform      = snowflake_account_role.transform.name
    analyst        = snowflake_account_role.analyst.name
  }
}
