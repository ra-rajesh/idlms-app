variable "env_name" { type = string }
variable "region" { type = string }

variable "platform_main_state_bucket" { type = string }
variable "platform_main_state_key" { type = string }

variable "ssm_env_param_path" {
  type    = string
  default = ""
}

variable "artifact_zip" {
  type    = string
  default = "backend-api.zip"
}

variable "rds_sg_id" {
  type    = string
  default = null
}

variable "artifact_bucket" {
  type = string
}

variable "artifact_key" {
  type = string
}
