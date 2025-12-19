output "masking_policies" {
  value = {
    email = snowflake_masking_policy.mask_email.name
    phone = snowflake_masking_policy.mask_phone.name
  }
}
