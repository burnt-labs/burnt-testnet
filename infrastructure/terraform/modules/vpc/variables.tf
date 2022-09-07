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
variable "cidr_range" {
  description = "CIDR range of the VPC"
  type        = string
}

variable "cidr_subnets_private" {
  description = "CIDR ranges of the private subnets"
  type        = list(string)
}

variable "cidr_subnets_public" {
  description = "CIDR ranges of the public subnets"
  type        = list(string)
}
