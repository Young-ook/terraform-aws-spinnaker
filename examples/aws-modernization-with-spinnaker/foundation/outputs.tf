output "vpc" {
  value = module.vpc.vpc
}

output "subnets" {
  value = module.vpc.subnets
}

output "eks_kubeconfig" {
  value = {
    context = module.eks.cluster.name
    script  = module.eks.kubeconfig
  }
}
