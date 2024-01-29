locals {
  short_region = var.region_names[var.aws_region]
}

# prevent deployments with default workspace
resource "null_resource" "assert_not_default" {
  count = terraform.workspace != "default" ? 0 : "Default workspace not allowed"
}

module "lambda" {
  source = "./lmb"

  service_name = var.service_name
  stack_name   = var.stack_name
  short_region = local.short_region
}

