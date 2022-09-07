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
variable "secrets_principals" {
  description = "Authorizations for the Secrets KMS key"
  type = object({
    encrypt = object({
      aws      = list(string)
      services = list(string)
    })
  })
}

variable "storage_principals" {
  description = "Authorizations for the Storage KMS key"
  type = object({
    encrypt = object({
      aws      = list(string)
      services = list(string)
    })
    grant = object({
      aws = list(string)
    })
  })
}
