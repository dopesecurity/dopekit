output "aws_region" {
  value = var.aws_region
}

output "stack_name" {
  value = var.stack_name
}

output "lmb_example_name" {
  value = module.lambda.lambda_function_name
}
