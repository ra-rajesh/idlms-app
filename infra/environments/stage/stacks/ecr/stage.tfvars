env_name             = "stage"
region               = "ap-south-1"
app_name             = "idlms-app"
repository_name      = "stage-idlms-app"
image_tag_mutability = "MUTABLE"
scan_on_push         = true
encryption_type      = "AES256"
ssm_prefix           = "/platform-main"

tags = {
  Project     = "idlms-app"
  Environment = "stage"
}
