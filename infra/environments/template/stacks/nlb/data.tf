data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = var.tf_bucket
    key            = "${var.env_name}/platform-main/network/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.lock_table
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket         = var.tf_bucket
    key            = "${var.env_name}/platform-main/compute/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.lock_table
  }
}

data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket         = var.tf_bucket
    key            = "${var.env_name}/platform-main/nlb/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.lock_table
  }
}
