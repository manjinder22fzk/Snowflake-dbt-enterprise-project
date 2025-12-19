variable "env" { type = string }

variable "analytics_database" { type = string } # e.g., ANALYTICS_DEV

# Roles that can see unmasked PII (keep small)
variable "unmasked_roles" {
  type    = list(string)
  default = []
}
