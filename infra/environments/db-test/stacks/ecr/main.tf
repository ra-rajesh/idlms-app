locals {
  tags = merge(
    {
      "Project"      = var.app_name
      "Environment"  = var.env_name
      "user:Project" = var.app_name
      "user:Env"     = var.env_name
      "user:Stack"   = "ecr"
    },
    var.tags
  )

  ssm_base = var.ssm_prefix == "" ? "" : format(
    "%s/%s/ecr/%s",
    trimsuffix(var.ssm_prefix, "/"),
    var.env_name,
    var.repository_name
  )
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # Allow tf destroy even if images exist (your pattern)
  force_delete = true
  tags         = local.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy_json == null ? 0 : 1
  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy_json
}

resource "aws_ssm_parameter" "repository_url" {
  count     = var.ssm_prefix == "" ? 0 : 1
  name      = "${local.ssm_base}/repository_url"
  type      = "String"
  value     = aws_ecr_repository.this.repository_url
  overwrite = true
  tags      = local.tags
}

resource "aws_ssm_parameter" "repository_arn" {
  count     = var.ssm_prefix == "" ? 0 : 1
  name      = "${local.ssm_base}/repository_arn"
  type      = "String"
  value     = aws_ecr_repository.this.arn
  overwrite = true
  tags      = local.tags
}

resource "aws_ssm_parameter" "repository_name" {
  count     = var.ssm_prefix == "" ? 0 : 1
  name      = "${local.ssm_base}/repository_name"
  type      = "String"
  value     = aws_ecr_repository.this.name
  overwrite = true
  tags      = local.tags
}
