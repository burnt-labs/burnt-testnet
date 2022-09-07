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
variable "cluster_ca_cert" {
  description = "CA certificate of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster API service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "oidc_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "chart_versions" {
  description = "The version of the Helm charts we want to apply"
  type = object({
    cluster_autoscaler = string
    ebs_csi            = string
    external_secrets   = string
    lb_controller      = string
  })
}

variable "storage_key_arn" {
  description = "ARN of the Storage KMS key"
  type        = string
}
