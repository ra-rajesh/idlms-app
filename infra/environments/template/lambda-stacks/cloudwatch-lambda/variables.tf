variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "app_name" {
  type    = string
  default = "idlms-app"
}

variable "retention_in_days" {
  type    = number
  default = 14
}

variable "tags" {
  type = map(string)
  default = {
    Project = "platform_main"
    Stack   = "cloudwatch-app"
  }
}
