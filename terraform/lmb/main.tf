locals {
  file_path = "${path.root}/../build/example_lambda.zip"
}

data "aws_iam_policy_document" "lmb-role-pol" {
  statement {
    sid = ""
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role-lmb" {
  name               = "rol-${var.short_region}-${var.stack_name}-${var.service_name}-example-lmb"
  assume_role_policy = data.aws_iam_policy_document.lmb-role-pol.json
}


resource "aws_lambda_function" "lambda" {
  filename      = local.file_path
  function_name = "lmb-${var.short_region}-${var.stack_name}-${var.service_name}-example"
  role          = aws_iam_role.role-lmb.arn
  handler       = "example_lambda.lambda_handler"

  source_code_hash = filebase64sha256(local.file_path)
  runtime          = "python3.11"

  timeout     = 3
  memory_size = 128

  tracing_config {
    mode = "Active"
  }

}


resource "aws_cloudwatch_log_group" "lambda-log" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "lmb-pol-doc" {
  statement {
    sid = "cloudwatchlogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda-log.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lmb-xray" {
  role       = aws_iam_role.role-lmb.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_policy" "lmb-policy" {
  name   = "pol-${var.short_region}-${var.stack_name}-${var.service_name}-lmb-example"
  policy = data.aws_iam_policy_document.lmb-pol-doc.json
}

resource "aws_iam_role_policy_attachment" "lmb-attachment" {
  role       = aws_iam_role.role-lmb.name
  policy_arn = aws_iam_policy.lmb-policy.arn
}
