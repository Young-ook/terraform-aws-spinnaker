# output variables 

output "cluster_name" {
  value       = local.name
  description = "The name of eks cluster to run spinnaker pods"
}

output "endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "The enpoint of eks cluster"
}

output "eks_sg" {
  value       = aws_security_group.eks.id
  description = "The id of security group for master nodes"
}

output "nodes_sg" {
  value       = aws_security_group.nodes.id
  description = "The id of security group for worker nodes (node pool)"
}

output "bucket_name" {
  value       = local.name
  description = "The name of s3 bucket to store pipelines and applications of spinnaker"
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "hosted_zone_id" {
  value = aws_route53_zone.vpc.zone_id
}
