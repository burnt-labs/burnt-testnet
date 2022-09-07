inputs = {
  aws   = local.defaults.aws
  label = local.defaults.label

  secrets_principals = {
    encrypt = {
      services = [
        "eks.amazonaws.com",
      ]
      aws = [
        format("arn:aws:iam::%s:role/burnt-use1testnet-node", local.defaults.aws.account_id),
      ]
    }
  }

  storage_principals = {
    encrypt = {
      services = [
        "ec2.amazonaws.com",
        "eks.amazonaws.com",
      ]
      aws = [
        format("arn:aws:iam::%s:role/burnt-use1testnet-ebs-csi", local.defaults.aws.account_id),
        format("arn:aws:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", local.defaults.aws.account_id)
      ]
    }
    grant = {
      aws = [
        format("arn:aws:iam::%s:role/burnt-use1testnet-ebs-csi", local.defaults.aws.account_id),
        format("arn:aws:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", local.defaults.aws.account_id)
      ]
    }
  }

}

locals {
  defaults = read_terragrunt_config(
    find_in_parent_folders("config.hcl")
  ).inputs
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//modules/kms"
}
