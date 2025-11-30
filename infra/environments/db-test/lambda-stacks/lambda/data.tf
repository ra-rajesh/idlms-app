data "terraform_remote_state" "platform_main" {
  backend = "s3"
  config = {
    bucket = var.platform_main_state_bucket
    key    = var.platform_main_state_key
    region = var.region
  }
}
