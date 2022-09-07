#
# Common vars
#
variable "aws" {
  description = "AWS provider variables"
  type = object({
    account_id = string
    region     = string
    role_arn   = string
  })
}

variable "label" {
  description = "Module labels"
  type = object({
    namespace   = string
    stage       = string
    environment = string
    tags        = map(string)
  })
}

#
# Specific vars
#
variable "addon_versions" {
  description = "Map of EKS Add-ons and their respective versions"
  type = object({
    coredns    = string
    kube_proxy = string
    vpc_cni    = string
  })
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.22`)"
  type        = string
  default     = null
}

variable "secrets_key_arn" {
  description = "ARN of the Secrets key to encrypt etcd"
  type        = string
}

variable "storage_key_arn" {
  description = "ARN of the Storage key to encrypt volumes"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets"
  type = object({
    private = set(string)
    public  = set(string)
  })
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
