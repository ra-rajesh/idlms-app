env_name             = "{{env.name}}"
region               = "{{aws.region}}"
app_name             = "{{app.name}}"
repository_name      = "{{env.name}}-{{app.name}}"
image_tag_mutability = "MUTABLE"
scan_on_push         = true
encryption_type      = "AES256"
ssm_prefix           = "/platform-main"

tags = {
  Project     = "{{app.name}}"
  Environment = "{{env.name}}"
}
