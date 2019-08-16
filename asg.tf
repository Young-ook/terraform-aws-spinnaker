# asg.tf
# auto scaling group

# container optimized ami
data "aws_ami" "eks-linux-ami" {
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kube_version}-*"]
  }
}

### kuberetes node-pool
resource "aws_iam_role" "node-pool" {
  name               = "${local.node_pool_name}"
  assume_role_policy = "${data.aws_iam_policy_document.node-pool-trustrel.json}"
}

data "aws_iam_policy_document" "node-pool-trustrel" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks-node-pool" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_role_policy_attachment" "eks-ecr-read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_instance_profile" "node-pool" {
  name = "${local.node_pool_name}"
  role = "${aws_iam_role.node-pool.name}"
}

# security/firewall
resource "aws_security_group" "node-pool" {
  name        = "${local.node_pool_name}"
  description = "security group for worker node of ${local.cluster_name}"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags = "${merge(
    map("Name", "${local.node_pool_name}"),
    "${local.k8s_tag_shared}",
  )}"
}

resource "aws_security_group_rule" "node-pool-ingress-allow-master-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "https traffic from master cluster"
  source_security_group_id = "${aws_security_group.master.id}"
  security_group_id        = "${aws_security_group.node-pool.id}"
}

resource "aws_security_group_rule" "node-pool-ingress-allow-master-tcp" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "https traffic from master cluster"
  source_security_group_id = "${aws_security_group.master.id}"
  security_group_id        = "${aws_security_group.node-pool.id}"
}

resource "aws_security_group_rule" "node-pool-ingress-allow-each-other" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "all traffics from other nodes"
  source_security_group_id = "${aws_security_group.node-pool.id}"
  security_group_id        = "${aws_security_group.node-pool.id}"
}

resource "aws_security_group_rule" "node-pool-egress-allow-all" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "all outbound traffics"
  security_group_id = "${aws_security_group.node-pool.id}"
}

# bootstrap
data "template_file" "node-pool-userdata" {
  template = "${file("${path.module}/res/node-pool.tpl")}"

  vars {
    name      = "${local.cluster_name}"
    endpoint  = "${aws_eks_cluster.master.endpoint}"
    cert_auth = "${aws_eks_cluster.master.certificate_authority.0.data}"
  }
}

# launch configuration
resource "aws_launch_configuration" "node-pool" {
  image_id             = "${var.kube_node_ami == "" ? data.aws_ami.eks-linux-ami.id : var.kube_node_ami}"
  instance_type        = "${var.kube_node_type}"
  name_prefix          = "${local.node_pool_name}-"
  security_groups      = ["${aws_security_group.node-pool.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.node-pool.name}"
  user_data            = "${data.template_file.node-pool-userdata.rendered}"

  root_block_device {
    volume_type = "${var.kube_node_vol_type}"
    volume_size = "${var.kube_node_vol_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# auto scaling group
resource "aws_autoscaling_group" "node-pool" {
  name                 = "${local.node_pool_name}"
  max_size             = "${var.kube_node_size}"
  min_size             = "${var.kube_node_size}"
  desired_capacity     = "${var.kube_node_size}"
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]
  availability_zones   = "${var.azs}"
  launch_configuration = "${aws_launch_configuration.node-pool.name}"
  termination_policies = ["Default"]
  force_delete         = true

  lifecycle {
    create_before_destroy = true
  }

  tags = ["${concat(list(
    map("key", "Name", "value", "${local.node_pool_name}", "propagate_at_launch", "true"),
    "${local.k8s_tag_owned}",
  ))}"]

  depends_on = [
    "aws_subnet.private",
  ]
}

### policy attachment to allow pods in node access aws resources

resource "aws_iam_role_policy_attachment" "spin-s3admin" {
  policy_arn = "${aws_iam_policy.s3admin.arn}"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_role_policy_attachment" "spin-bake" {
  policy_arn = "${aws_iam_policy.rosco-bake.arn}"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_role_policy_attachment" "spin-ec2read" {
  policy_arn = "${aws_iam_policy.spin-ec2read.arn}"
  role       = "${aws_iam_role.node-pool.name}"
}

resource "aws_iam_role_policy_attachment" "spin-assume" {
  policy_arn = "${aws_iam_policy.spin-assume.arn}"
  role       = "${aws_iam_role.node-pool.name}"
}

# security/firewall
resource "aws_security_group" "rosco-bake" {
  name        = "${local.node_pool_name}-bake"
  description = "security group for image baker of ${local.cluster_name}"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags = "${merge(
    map("Name", "${local.node_pool_name}-bake"),
    "${local.k8s_tag_shared}",
  )}"
}

resource "aws_security_group_rule" "rosco-bake-ingress-allow-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "ssh traffic from packer in rosco"
  source_security_group_id = "${aws_security_group.node-pool.id}"
  security_group_id        = "${aws_security_group.rosco-bake.id}"
}

resource "aws_security_group_rule" "rosco-bake-egress-allow-all" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "all outbound traffics"
  security_group_id = "${aws_security_group.rosco-bake.id}"
}
