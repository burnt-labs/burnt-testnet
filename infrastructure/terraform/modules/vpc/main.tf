#
# Label
# see: https://github.com/cloudposse/terraform-null-label
#
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.label.namespace
  stage       = var.label.stage
  name        = "vpc"
  environment = var.label.environment
  tags        = var.label.tags

  label_order = ["namespace", "environment", "name"]
}

locals {
  eks_cluster_name = "${module.label.namespace}-${module.label.environment}"
}

#
# VPC
# see: https://github.com/terraform-aws-modules/terraform-aws-vpc
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = module.label.id
  cidr = var.cidr_range

  azs             = ["${var.aws.region}a", "${var.aws.region}b", "${var.aws.region}c"]
  private_subnets = var.cidr_subnets_private
  public_subnets  = var.cidr_subnets_public

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = 1
  }

  tags = {
    for k, v in module.label.tags :
    k => v if k != "Name"
  }
}
