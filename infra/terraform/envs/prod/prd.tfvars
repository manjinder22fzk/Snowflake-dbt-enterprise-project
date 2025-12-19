env = "PRD"

# Snowflake connection (prefer env vars in terminal, but tfvars is ok for non-secret items)
snowflake_org     = "IKAYRWG"
snowflake_account = "EV72390"

# snowflake_user = "value"
# snowflake_password = "value"
# I will set using env variables



terraform_role      = "ACCOUNTADMIN"
terraform_warehouse = "WH_PRD_ADMIN_XS"

# Preview features: keep empty until we actually use preview resources in later phases.
preview_features_enabled = []


