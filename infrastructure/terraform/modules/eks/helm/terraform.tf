provider "aws" {
  allowed_account_ids = [var.aws.account_id]
  region              = var.aws.region

  assume_role {
    role_arn = var.aws.role_arn
  }
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.cluster_id
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

terraform {
  backend "s3" {}
}
