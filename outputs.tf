# output variables 

output "cluster_name" {
  value       = local.name
  description = "The name of eks cluster to run spinnaker pods"
}

output "eks_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "The enpoint of eks cluster"
}

output "bucket_name" {
  value       = local.name
  description = "The name of s3 bucket to store pipelines and applications of spinnaker"
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The Id. of new VPC"
}

output "public_subnets" {
  value       = aws_subnet.public.*.id
  description = "The Id. list of generated public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private.*.id
  description = "The Id. list of generated private subnets"
}

output "hosted_zone_id" {
  value       = aws_route53_zone.vpc.zone_id
  description = "The hosted zone Id. of internal domain in Route 53"
}

output "db_endpoint" {
  value       = aws_route53_record.db.*.name
  description = "The enpoint of aurora mysql cluster"
}
