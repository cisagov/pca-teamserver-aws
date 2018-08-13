# Security group for the PCA teamserver
resource "aws_security_group" "teamserver" {
  vpc_id = "${aws_vpc.vpc.id}"
  
  tags = "${merge(var.tags, map("Name", "PCA Teamserver Security Group"))}"
}

# Allow ssh and Cobalt Strike ingress from trusted networks.  The
# ports are defined with the corresponding ACL rules.
resource "aws_security_group_rule" "teamserver_ingress_from_trusted" {
  count = "${length(local.ingress_ports)}"
  
  security_group_id = "${aws_security_group.teamserver.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = "${var.trusted_ingress_networks_ipv4}"
  # ipv6_cidr_blocks = "${var.trusted_ingress_networks_ipv6}"
  from_port = "${local.ingress_ports[count.index]}"
  to_port = "${local.ingress_ports[count.index]}"
}

# Allow egress anywhere via HTTP, HTTPS, and SMTP (25, 143, 587, 993).
# The ports are defined with the corresponding ACL rules.
resource "aws_security_group_rule" "teamserver_egress" {
  count = "${length(local.egress_ports)}"
  
  security_group_id = "${aws_security_group.teamserver.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  # ipv6_cidr_blocks = ["::/0"]
  from_port = "${local.egress_ports[count.index]}"
  to_port = "${local.egress_ports[count.index]}"
}
