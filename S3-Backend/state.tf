terraform {
  backend "s3" {
    bucket = "yiting-terraform-state-devops"
    key = "state/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    kms_key_id = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"
  }
}


# KMS key to allow for the encryption of the state bucket
# KMS alias, which will be referred to later
# S3 bucket with all of the appropriate security configurations
# DynamoDB table, which allows for the locking of the state file

resource "aws_kms_key" "terraform-bucket-key" {
  description = "This key is used to encrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "key-alias" {
  target_key_id = aws_kms_key.terraform-bucket-key.id
  name = "alias/terraform-bucket-key"
}


resource "aws_s3_bucket" "terraform-state-devops-yiting" {
  bucket = "yiting-terraform-state-devops"
  acl = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform-state-devops-yiting.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# To prevent two team members from writing to the state file at the same time
# we will implement a DynamoDB table lock

resource "aws_dynamodb_table" "terraform-state" {
  hash_key = "LockID"
  name     = "terraform-state"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}

