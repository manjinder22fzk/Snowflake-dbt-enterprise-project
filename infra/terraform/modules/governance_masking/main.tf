locals {
  security_schema = "${var.analytics_database}.SECURITY"
}


resource "snowflake_masking_policy" "mask_email" {
  name     = "MP_${var.env}_EMAIL"
  database = var.analytics_database
  schema   = "SECURITY"

  argument {
    name = "VAL"
    type = "VARCHAR"
  }
  

  return_data_type = "VARCHAR"

  # If role is allowed, show real value; else mask.
  # This uses CURRENT_ROLE() checks (enterprise common pattern).
  body = <<SQL
CASE
  WHEN CURRENT_ROLE() IN (${join(", ", [for r in var.unmasked_roles : "'${r}'"])}) THEN VAL
  WHEN VAL IS NULL THEN NULL
  ELSE REGEXP_REPLACE(VAL, '(^.).*(@.*$)', '\\1*****\\2')
END
SQL
}

#############################
# Masking policy for PHONE
#############################
resource "snowflake_masking_policy" "mask_phone" {
  name     = "MP_${var.env}_PHONE"
  database = var.analytics_database
  schema   = "SECURITY"

  argument {
    name = "VAL"
    type = "VARCHAR"
  }

  return_data_type = "VARCHAR"

  body = <<SQL
CASE
  WHEN CURRENT_ROLE() IN (${join(", ", [for r in var.unmasked_roles : "'${r}'"])}) THEN VAL
  WHEN VAL IS NULL THEN NULL
  ELSE '***-***-' || RIGHT(VAL, 4)
END
SQL
}
