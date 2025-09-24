variable "clients" {
  description = "List of active clients with fields: name, env, region"
  type = list(object({
    name   = string
    env    = string
    region = string
  }))
}


