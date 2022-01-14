terraform {
  required_providers {
    docker= {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
  backend "s3" {
    bucket = "yiting-terraform-ecs-devops"
    key = "docker/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state"
    kms_key_id = "alias/terraform-bucket-key"
    encrypt = true
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
