# outputs.tf

output "cluster_name" {
  value = "${local.name}"
}

output "endpoint" {
  value = "${aws_eks_cluster.master.endpoint}"
}

output "master_sg" {
  value = "${aws_security_group.master.id}"
}

output "node_pool_sg" {
  value = "${aws_security_group.node-pool.id}"
}

output "bucket_name" {
  value = "${local.name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnets" {
  value = "${aws_subnet.public.*.id}"
}

output "private_subnets" {
  value = "${aws_subnet.private.*.id}"
}

output "hosted_zone_id" {
  value = "${aws_route53_zone.vpc.zone_id}"
}
