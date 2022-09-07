output "node" {
  description = "Available Elastic IPs"
  value = { for k, v in aws_eip.node :
    k => {
      id          = v.id
      private_dns = v.private_dns
      private_ip  = v.private_ip
      public_dns  = v.public_dns
      public_ip   = v.public_ip
    }
  }
}
