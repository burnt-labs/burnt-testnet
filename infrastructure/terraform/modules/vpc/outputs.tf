output "vpc" {
  value = {
    nat_public_ips = module.vpc.nat_public_ips
    subnet_ids = {
      private = module.vpc.private_subnets
      public  = module.vpc.public_subnets
    }
    vpc_id = module.vpc.vpc_id
  }
}
