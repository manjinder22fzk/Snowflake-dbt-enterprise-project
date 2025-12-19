variable "env" {
  type        = string
  description = "Environment name: dev/prod"
}

variable "snowflake_org" {
  type        = string
  description = "Snowflake org name (not locator)"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake account name (not locator)"
}

variable "snowflake_user" {
  type        = string
  description = "Terraform operator user"
}

variable "snowflake_password" {
  type        = string
  sensitive   = true
  description = "Password for Terraform operator user"
}

variable "terraform_role" {
  type        = string
  description = "Role Terraform uses for this run (ACCOUNTADMIN for bootstrap; Terraform role after)"
}

variable "terraform_warehouse" {
  type        = string
  description = "Warehouse Terraform uses for this run"
}

variable "preview_features_enabled" {
  type        = list(string)
  default     = []
  description = "Provider preview features to enable"
}


