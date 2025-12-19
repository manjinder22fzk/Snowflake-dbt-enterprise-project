provider "snowflake" {
  # Password auth (simple for learning). Put these in env vars, NOT in code.
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  password          = var.snowflake_password

  role = var.terraform_role
  # warehouse = var.terraform_warehouse

  # Preview features are disabled by default; we keep this parameterized.
  preview_features_enabled = var.preview_features_enabled
}
