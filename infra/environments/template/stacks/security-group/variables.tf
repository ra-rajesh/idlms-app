
variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "tf_bucket" {
  type = string
}

variable "lock_table" {
  type = string
}

variable "app_port" {
  type    = number
  default = 4000
}
