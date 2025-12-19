locals {
  # Functional roles (from Phase 2 module)
  r_platform_admin = "R_${var.env}_PLATFORM_ADMIN"
  r_ingest         = "R_${var.env}_INGEST"
  r_transform      = "R_${var.env}_TRANSFORM"
  r_analyst        = "R_${var.env}_ANALYST"

  # Access roles (new)
  ar_raw_load           = "AR_${var.env}_RAW_LOAD"
  ar_raw_read           = "AR_${var.env}_RAW_READ"
  ar_analytics_transform = "AR_${var.env}_ANALYTICS_TRANSFORM"
  ar_gold_read          = "AR_${var.env}_GOLD_READ"

  # Convenient fully qualified schema names
  raw_landing     = "${var.databases.raw}.LANDING"
  raw_bronze      = "${var.databases.raw}.BRONZE"
  an_silver       = "${var.databases.analytics}.SILVER"
  an_gold         = "${var.databases.analytics}.GOLD"
  an_security     = "${var.databases.analytics}.SECURITY"
  raw_util        = "${var.databases.raw}.UTIL"
  raw_schemachange = "${var.databases.raw}.SCHEMACHANGE"
}

############################################
# 1) Create access roles
############################################
resource "snowflake_account_role" "ar_raw_load" {
  name    = local.ar_raw_load
  comment = "Access role: load files + create landing objects + load BRONZE in ${var.databases.raw}"
}

resource "snowflake_account_role" "ar_raw_read" {
  name    = local.ar_raw_read
  comment = "Access role: read BRONZE objects in ${var.databases.raw}"
}

resource "snowflake_account_role" "ar_analytics_transform" {
  name    = local.ar_analytics_transform
  comment = "Access role: dbt transformations in ${var.databases.analytics} (SILVER/GOLD)"
}

resource "snowflake_account_role" "ar_gold_read" {
  name    = local.ar_gold_read
  comment = "Access role: read GOLD marts in ${var.databases.analytics}.GOLD"
}

############################################
# 2) Grant access roles to functional roles
#    (role hierarchy) — enterprise best practice
############################################
resource "snowflake_grant_account_role" "raw_load_to_ingest" {
  role_name        = snowflake_account_role.ar_raw_load.name
  parent_role_name = local.r_ingest
}

resource "snowflake_grant_account_role" "raw_read_to_transform" {
  role_name        = snowflake_account_role.ar_raw_read.name
  parent_role_name = local.r_transform
}

resource "snowflake_grant_account_role" "analytics_transform_to_transform" {
  role_name        = snowflake_account_role.ar_analytics_transform.name
  parent_role_name = local.r_transform
}

resource "snowflake_grant_account_role" "gold_read_to_analyst" {
  role_name        = snowflake_account_role.ar_gold_read.name
  parent_role_name = local.r_analyst
}

# Platform admin gets everything
resource "snowflake_grant_account_role" "raw_load_to_platform_admin" {
  role_name        = snowflake_account_role.ar_raw_load.name
  parent_role_name = local.r_platform_admin
}

resource "snowflake_grant_account_role" "raw_read_to_platform_admin" {
  role_name        = snowflake_account_role.ar_raw_read.name
  parent_role_name = local.r_platform_admin
}

resource "snowflake_grant_account_role" "analytics_transform_to_platform_admin" {
  role_name        = snowflake_account_role.ar_analytics_transform.name
  parent_role_name = local.r_platform_admin
}

resource "snowflake_grant_account_role" "gold_read_to_platform_admin" {
  role_name        = snowflake_account_role.ar_gold_read.name
  parent_role_name = local.r_platform_admin
}

############################################
# 3) Privileges: warehouses (USAGE)
############################################
resource "snowflake_grant_privileges_to_account_role" "raw_load_wh_usage" {
  account_role_name = snowflake_account_role.ar_raw_load.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouses.load
  }
}

resource "snowflake_grant_privileges_to_account_role" "analytics_transform_wh_usage" {
  account_role_name = snowflake_account_role.ar_analytics_transform.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouses.dbt
  }
}

resource "snowflake_grant_privileges_to_account_role" "gold_read_wh_usage" {
  account_role_name = snowflake_account_role.ar_gold_read.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouses.bi
  }
}

############################################
# 4) Privileges: database USAGE
############################################
resource "snowflake_grant_privileges_to_account_role" "raw_db_usage_raw_load" {
  account_role_name = snowflake_account_role.ar_raw_load.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.databases.raw
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_db_usage_raw_read" {
  account_role_name = snowflake_account_role.ar_raw_read.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.databases.raw
  }
}

resource "snowflake_grant_privileges_to_account_role" "analytics_db_usage_transform" {
  account_role_name = snowflake_account_role.ar_analytics_transform.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.databases.analytics
  }
}

resource "snowflake_grant_privileges_to_account_role" "analytics_db_usage_gold_read" {
  account_role_name = snowflake_account_role.ar_gold_read.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.databases.analytics
  }
}

############################################
# 5) Privileges: schema USAGE + CREATE (where needed)
############################################
# RAW_LOAD: LANDING schema (stages + file formats)
resource "snowflake_grant_privileges_to_account_role" "raw_load_landing_schema" {
  account_role_name = snowflake_account_role.ar_raw_load.name
  privileges        = ["USAGE", "CREATE STAGE", "CREATE FILE FORMAT"]
  on_schema {
    schema_name = local.raw_landing
  }
}

# RAW_LOAD: BRONZE schema (create/load tables; streams/tasks later)
resource "snowflake_grant_privileges_to_account_role" "raw_load_bronze_schema" {
  account_role_name = snowflake_account_role.ar_raw_load.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STREAM", "CREATE TASK"]
  on_schema {
    schema_name = local.raw_bronze
  }
}

# RAW_READ: BRONZE schema USAGE
resource "snowflake_grant_privileges_to_account_role" "raw_read_bronze_schema_usage" {
  account_role_name = snowflake_account_role.ar_raw_read.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = local.raw_bronze
  }
}

# TRANSFORM: SILVER/GOLD create privileges (dbt needs create table/view)
resource "snowflake_grant_privileges_to_account_role" "transform_silver_schema" {
  account_role_name = snowflake_account_role.ar_analytics_transform.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  on_schema {
    schema_name = local.an_silver
  }
}

resource "snowflake_grant_privileges_to_account_role" "transform_gold_schema" {
  account_role_name = snowflake_account_role.ar_analytics_transform.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  on_schema {
    schema_name = local.an_gold
  }
}

# GOLD_READ: GOLD schema USAGE
resource "snowflake_grant_privileges_to_account_role" "gold_read_gold_schema_usage" {
  account_role_name = snowflake_account_role.ar_gold_read.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = local.an_gold
  }
}

############################################
# 6) Object privileges: SELECT on ALL + FUTURE objects
#    This is critical for enterprise ops so permissions don’t break on new models.
############################################
# RAW_READ: SELECT on all existing + future tables in RAW.BRONZE
resource "snowflake_grant_privileges_to_account_role" "raw_read_select_all_tables" {
  account_role_name = snowflake_account_role.ar_raw_read.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = local.raw_bronze
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_read_select_future_tables" {
  account_role_name = snowflake_account_role.ar_raw_read.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = local.raw_bronze
    }
  }
}

# GOLD_READ: SELECT on all existing + future tables in ANALYTICS.GOLD
resource "snowflake_grant_privileges_to_account_role" "gold_read_select_all_tables" {
  account_role_name = snowflake_account_role.ar_gold_read.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = local.an_gold
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "gold_read_select_future_tables" {
  account_role_name = snowflake_account_role.ar_gold_read.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = local.an_gold
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_load_util_schema" {
  account_role_name = snowflake_account_role.ar_raw_load.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE TASK", "CREATE PROCEDURE"]
  on_schema {
    schema_name = local.raw_util
  }
}

resource "snowflake_grant_privileges_to_account_role" "raw_load_schemachange_schema" {
  account_role_name = snowflake_account_role.ar_raw_load.name

  privileges = [
    "USAGE",
    "CREATE TABLE",
    "CREATE VIEW"
  ]

  on_schema {
    schema_name = local.raw_schemachange
  }
}
