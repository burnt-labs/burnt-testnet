provider "aws" {
  allowed_account_ids = [var.aws.account_id]
  region              = var.aws.region

  assume_role {
    role_arn = var.aws.role_arn
  }
}

terraform {
  backend "s3" {}
}
