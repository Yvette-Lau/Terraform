terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">=0.14.9"

}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  tags = {
    Name = "Terrform_Demo"
  }
}

