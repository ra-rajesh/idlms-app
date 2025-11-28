variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "param_name" {
  type    = string
  default = "/platform-main/stage/idlms-app/.env"
}

variable "app_env_content" {
  type      = string
  sensitive = true
  default   = "MANAGED_EXTERNALLY"
}

variable "app_name" {
  type = string
}
