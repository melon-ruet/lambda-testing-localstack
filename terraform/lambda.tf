locals {
  // Lambda code zip directory
  lambda_artifact_dir = "${path.module}/lambda_zip"
  python_version = "python${data.external.python_version.result.version}"
}

// Grab python version from Pipfile. Default is 3.8 if not mentioned // in Pipfile
data "external" "python_version" {
  program = [
    "python3",
    "-c",
    "from pipenv.project import Project as P; import json; _p = P(chdir=False); print(json.dumps({'version': _p.required_python_version or '3.8'}))"
  ]
}

// Zip lambda function codes
data "archive_file" "lambda_zip_file" {
  output_path = "${local.lambda_artifact_dir}/lambda.zip"
  source_dir  = "${path.module}/../lambda"
  excludes    = ["__pycache__", "*.pyc"]
  type        = "zip"
}

# IAM Policy document for lambda assume role
data "aws_iam_policy_document" "lambda_assume_role" {
  version = "2012-10-17"

  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

// Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name               = "test-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  lifecycle {
    create_before_destroy = true
  }
}
// Lambda function terraform code
resource "aws_lambda_function" "lambda_function" {
  function_name    = "test-lambda-function"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "handler.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = local.python_version

  lifecycle {
    create_before_destroy = true
  }
}