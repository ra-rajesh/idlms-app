env_name = "{{env.name}}"
region   = "{{aws.region}}"

# api_name   = "idlms-api"
# stage_name = "db-test"

# platform_main_state_bucket = "db-test-btl-platform-main-repo-backend-tfstate-592776312448"
platform_main_state_key = "{{env.name}}/platform-main/network/terraform.tfstate"

# artifact_bucket = "db-test-btl-platform-main-repo-backend-artifact-592776312448"
artifact_key = "{{env.name}}/{{app.name}}-lambda/backend-api.zip"
# rds_sg_id = ""
