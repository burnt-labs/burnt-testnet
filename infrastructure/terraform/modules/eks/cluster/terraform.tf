provider "aws" {
  allowed_account_ids = [var.aws.account_id]
  region              = var.aws.region

  assume_role {
    role_arn = var.aws.role_arn
  }
}

provider "kubernetes" {
  # aws eks update-kubeconfig --name $clusterName --role $clusterCreationRole
  config_path = "~/.kube/config"
}

terraform {
  backend "s3" {}
}
