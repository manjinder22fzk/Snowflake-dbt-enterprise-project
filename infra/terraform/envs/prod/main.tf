module "foundation" {
  source = "../../modules/snowflake_foundation"

  env = var.env

  databases = {
    raw       = "RAW_${var.env}"
    analytics = "ANALYTICS_${var.env}"
  }

  # Medallion + platform schemas
  schemas = {
    "RAW_${var.env}"       = ["LANDING", "BRONZE", "UTIL", "SCHEMACHANGE"]
    "ANALYTICS_${var.env}" = ["SILVER", "GOLD", "SECURITY", "UTIL"]
  }

  warehouses = {
    load  = "WH_${var.env}_LOAD_XS"
    dbt   = "WH_${var.env}_DBT_S"
    bi    = "WH_${var.env}_BI_XS"
    admin = "WH_${var.env}_ADMIN_XS"
  }
}

module "access" {
  source = "../../modules/snowflake_access"

  env = var.env

  databases = {
    raw       = "RAW_${var.env}"
    analytics = "ANALYTICS_${var.env}"
  }

  warehouses = {
    load  = "WH_${var.env}_LOAD_XS"
    dbt   = "WH_${var.env}_DBT_S"
    bi    = "WH_${var.env}_BI_XS"
    admin = "WH_${var.env}_ADMIN_XS"
  }

  depends_on = [module.foundation]
}

module "governance_masking" {
  source = "../../modules/governance_masking"

  env                = var.env
  analytics_database = "ANALYTICS_${var.env}"

  # Only these roles see raw PII
  unmasked_roles = [
    "R_${var.env}_PLATFORM_ADMIN",
    "R_${var.env}_TRANSFORM"
  ]

  depends_on = [module.foundation, module.access]
}
