# main.tf | Main Configuration
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "yiting-terraform-ecs-devops"
    key = "ECS/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state"
    kms_key_id = "alias/terraform-bucket-key"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

