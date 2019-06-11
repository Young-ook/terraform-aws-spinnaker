resource "aws_route53_zone" "vpc" {
  name = "${var.dns_zone}"
  tags = "${merge(map("Name", "${local.name}-r53"), var.tags)}"

  vpc {
    vpc_id = "${aws_vpc.vpc.id}"
  }
}
