terraform {
  backend "s3" {
    bucket = "yiting-terraform-state-devops"
    encrypt = true
    key = "state/terraform.tfstate"
    region = "us-east-1"
    kms_key_id = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"
  }
}
provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
