########################
# Databases
########################
resource "snowflake_database" "raw" {
  name = var.databases.raw

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "snowflake_database" "analytics" {
  name = var.databases.analytics

  # lifecycle {
  #   prevent_destroy = true
  # }
}

########################
# Schemas
########################
locals {
  schema_pairs = flatten([
    for db, schema_list in var.schemas : [
      for s in schema_list : {
        db     = db
        schema = s
      }
    ]
  ])

  db_resource_name = {
    (var.databases.raw)       = snowflake_database.raw.name
    (var.databases.analytics) = snowflake_database.analytics.name
  }

}

resource "snowflake_schema" "schemas" {
  for_each = {
    for p in local.schema_pairs : "${p.db}.${p.schema}" => p
  }

  database = local.db_resource_name[each.value.db]
  name     = each.value.schema

  # lifecycle {
  #   prevent_destroy = true
  # }
}

########################
# Warehouses (workload separated)
########################
resource "snowflake_warehouse" "wh" {
  for_each = var.warehouses

  name           = each.value
  warehouse_size = "XSMALL"

  auto_suspend = 60
  auto_resume  = true

  initially_suspended = true

  # lifecycle {
  #   prevent_destroy = true
  # }
}

########################
# RBAC Roles (created now; fine-grained grants later)
########################
resource "snowflake_account_role" "platform_admin" {
  name = "R_${var.env}_PLATFORM_ADMIN"
}

resource "snowflake_account_role" "ingest" {
  name = "R_${var.env}_INGEST"
}

resource "snowflake_account_role" "transform" {
  name = "R_${var.env}_TRANSFORM"
}

resource "snowflake_account_role" "analyst" {
  name = "R_${var.env}_ANALYST"
}

# Role hierarchy (child roles granted to platform admin)
resource "snowflake_grant_account_role" "ingest_to_admin" {
  role_name        = snowflake_account_role.ingest.name
  parent_role_name = snowflake_account_role.platform_admin.name
}

resource "snowflake_grant_account_role" "transform_to_admin" {
  role_name        = snowflake_account_role.transform.name
  parent_role_name = snowflake_account_role.platform_admin.name
}

resource "snowflake_grant_account_role" "analyst_to_admin" {
  role_name        = snowflake_account_role.analyst.name
  parent_role_name = snowflake_account_role.platform_admin.name
}
