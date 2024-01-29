variable "region_names" {
  description = "Mapping of AWS region names to shorter, dope names"
  default = {
    "us-east-2"      = "use2"
    "eu-central-1"   = "euc1"
    "ap-southeast-1" = "apse1"
  }
}

variable "primary_region" {
  description = "The primary region for DAS, where the dynamo tables are deployed from"
  default     = "us-east-2"
}

variable "stack_name" {
  description = "Unique identifier for deployment. Injected in all resource names"
}

variable "aws_region" {
  description = "Name of region to deploy into, using AWS naming convention"
}

variable "deployer_id" {
  description = "User email or Circle CI build ID of deployer."
}

variable "service_name" {
  default     = FIXME
  description = "The abbreviated name of the service: FIXME!"
}

variable "layer_zip_file_path" {
  description = "Path to the zip file with the code for the lambda layer"
  default     = "../build/shared_layer.zip"
}
