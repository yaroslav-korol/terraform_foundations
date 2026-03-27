output "default_security_group_id" {
    value = module.vpc.default_security_group_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}