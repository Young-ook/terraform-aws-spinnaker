output "vpc" {
  value = module.vpc.vpc
}

output "subnets" {
  value = module.vpc.subnets
}

output "eks" {
  value = {
    cluster = module.eks.cluster
    script  = module.eks.kubeconfig
  }
}
