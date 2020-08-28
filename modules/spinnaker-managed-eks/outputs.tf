# output variables 

output "name" {
  value       = local.name
  description = "The EKS cluster name"
}

output "cluster" {
  value       = aws_eks_cluster.cp
  description = "The EKS cluster attributes"
}

output "role_arn" {
  value       = aws_iam_role.ng.arn
  description = "The generated role ARN of the EKS node group"
}

output "tags" {
  value = {
    "shared"       = local.eks-shared-tag
    "owned"        = local.eks-owned-tag
    "elb"          = local.eks-elb-tag
    "internal-elb" = local.eks-internal-elb-tag
  }
  description = "The generated tags for EKS integration"
}

output "oidc_url" {
  value       = local.oidc["url"]
  description = "The URL on the EKS cluster OIDC issuer"
}

output "oidc_arn" {
  value       = local.oidc["arn"]
  description = "The ARN of OIDC provider"
}

output "kubeconfig" {
  value = join(" ", [
    "bash -e",
    format("%s/script/update-kubeconfig.sh", path.module),
    format("-r %s", data.aws_region.current.name),
    format("-n %s", aws_eks_cluster.cp.name),
    "-s true",
  ])
  description = "Bash script to update kubeconfig file"
}
