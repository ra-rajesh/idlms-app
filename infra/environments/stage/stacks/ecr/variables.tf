variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# The single repo you want to create from idlms-app
variable "repository_name" {
  type    = string
  default = "idlms-app"
}

# or IMMUTABLE
variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

# or KMS
variable "encryption_type" {
  type    = string
  default = "AES256"
}

# Optional lifecycle policy as a raw JSON string; if null, lifecycle is skipped
variable "lifecycle_policy_json" {
  type    = string
  default = null
}

variable "ssm_prefix" {
  type    = string
  default = "/platform-main"
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "app_name" {
  type = string
}
