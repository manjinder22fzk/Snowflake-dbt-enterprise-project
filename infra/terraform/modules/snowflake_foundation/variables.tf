variable "env" { type = string }

variable "databases" {
  type = object({
    raw       = string
    analytics = string
  })
}

variable "schemas" {
  # map(database_name -> list(schema_names))
  type = map(list(string))
}

variable "warehouses" {
  type = map(string)
}
