variable "aws_region" {
  type        = string
  description = "AWS Region"
}
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "dockerhub_credentials" {
  type = string
  description = "credentials for dockerhub to pull images"
}

variable "codestar_connector_credentials" {
  type = string
  description = "credentials to connect the github repository"
}