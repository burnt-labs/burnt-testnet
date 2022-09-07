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
variable "repositories" {
  description = "Name of the ECR repos to create"
  type        = set(string)
}

variable "storage_key_arn" {
  description = "ARN of the Storage key to encrypt container images"
  type        = string
}
