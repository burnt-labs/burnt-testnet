inputs = {
  aws = {
    account_id = "my-aws-account-id"
    region     = "us-east-1"
    role_arn   = "my-terraform-role-arn"
  }
  label = {
    namespace   = "burnt"
    stage       = "testnet"
    environment = "use1testnet"
    tags        = {}
  }
}
