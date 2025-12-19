variable "env" { type = string }

variable "databases" {
  type = object({
    raw       = string
    analytics = string
  })
}

variable "warehouses" {
  type = object({
    load  = string
    dbt   = string
    bi    = string
    admin = string
  })
}
