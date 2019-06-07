# Security group for the PCA teamserver
resource "aws_security_group" "teamserver" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "PCA Teamserver Security Group"
    },
  )
}

# Allow ingress on certain ports from trusted networks.  The ports are
# defined with the corresponding ACL rules.
resource "aws_security_group_rule" "teamserver_ingress_from_trusted" {
  count = length(local.trusted_ingress_ports)

  security_group_id = aws_security_group.teamserver.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = var.trusted_ingress_networks_ipv4

  # ipv6_cidr_blocks = "${var.trusted_ingress_networks_ipv6}"
  from_port = local.trusted_ingress_ports[count.index]
  to_port   = local.trusted_ingress_ports[count.index]
}

# Allow ingress on certain other ports from untrusted networks.  The
# ports are defined with the corresponding ACL rules.
resource "aws_security_group_rule" "teamserver_ingress_from_untrusted" {
  count = length(local.untrusted_ingress_ports)

  security_group_id = aws_security_group.teamserver.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]

  # ipv6_cidr_blocks = ["::/0"]
  from_port = local.untrusted_ingress_ports[count.index]
  to_port   = local.untrusted_ingress_ports[count.index]
}

# Allow egress anywhere via certain ports.  The ports are defined with
# the corresponding ACL rules.
resource "aws_security_group_rule" "teamserver_egress" {
  count = length(local.egress_ports)

  security_group_id = aws_security_group.teamserver.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]

  # ipv6_cidr_blocks = ["::/0"]
  from_port = local.egress_ports[count.index]
  to_port   = local.egress_ports[count.index]
}
