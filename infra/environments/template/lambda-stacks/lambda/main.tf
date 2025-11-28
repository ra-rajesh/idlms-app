locals {
  fn_name = "${var.env_name}-idlms-app-lambda"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.fn_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ssm" {
  name = "${local.fn_name}-ssm"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      Resource = "arn:aws:ssm:${var.region}:*:parameter/platform-main/${var.env_name}/idlms-app-lambda/*"
    }]
  })
}

resource "aws_security_group" "lambda_sg" {
  name        = "${local.fn_name}-sg"
  description = "Lambda SG for idlms-app-lambda"
  vpc_id      = data.terraform_remote_state.platform_main.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# optional rds allow-listing (if rds_sg_id provided)
resource "aws_security_group_rule" "allow_lambda_to_rds" {
  count                    = var.rds_sg_id == null ? 0 : 1
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_sg_id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow Lambda to reach Postgres"
}

resource "aws_lambda_function" "app" {
  function_name = local.fn_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "nodejs18.x"
  handler       = "dist/lambda.handler"

  s3_bucket        = var.artifact_bucket
  s3_key           = var.artifact_key
  source_code_hash = fileexists(var.artifact_zip) ? filebase64sha256(var.artifact_zip) : null

  memory_size = 512
  timeout     = 30
  publish     = true

  vpc_config {
    subnet_ids         = data.terraform_remote_state.platform_main.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      APP_DOTENV  = "/platform-main/${var.env_name}/idlms-app-lambda/.env"
      ENV         = var.env_name
      NODE_ENV    = "production"
      HEALTH_PATH = "/health"
      LOG_LEVEL   = "info"
    }
  }
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.app.function_name
  function_version = aws_lambda_function.app.version
}
