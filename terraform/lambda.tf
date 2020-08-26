// Zip lambda function codes
data "archive_file" "lambda_zip_file" {
  output_path = "${local.lambda_artifact_dir}/lambda.zip"
  source_dir  = "${path.module}/../lambda"
  excludes    = ["__pycache__", "*.pyc"]
  type        = "zip"
}

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
  layers           = [aws_lambda_layer_version.lambda_layer.arn]

  lifecycle {
    create_before_destroy = true
  }
}