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

# to allow from private subnets (NLB ENIs live there)
data "aws_subnet" "priv" {
  for_each = toset(data.terraform_remote_state.network.outputs.private_subnet_ids)
  id       = each.value
}
