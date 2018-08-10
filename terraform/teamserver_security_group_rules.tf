# Security group for the PCA teamserver
resource "aws_security_group" "teamserver" {
  tags = "${merge(var.tags, map("Name", "Teamserver Security Group"))}"
}

# Allow ssh and Cobalt Strike ingress from trusted networks
locals {
  ingress_ports = [
    22,
    50050
  ]
}
resource "aws_security_group_rule" "teamserver_ingress_from_trusted" {
  count = 2
  
  security_group_id = "${aws_security_group.teamserver.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = "${var.trusted_ingress_networks_ipv4}"
  # ipv6_cidr_blocks = "${var.trusted_ingress_networks_ipv6}"
  from_port = "${local.ingress_ports[count.index]}"
  to_port = "${local.ingress_ports[count.index]}"
}

# Allow ingress to and from the teamserver via ssh.  This is necessary
# because Ansible applies the ssh proxy even when sshing to the
# bastion.
locals {
  in_and_out = [
    "ingress",
    "egress"
  ]
}
resource "aws_security_group_rule" "teamserver_self_ssh" {
  count = 2
  
  security_group_id = "${aws_security_group.teamserver.id}"
  type = "${local.in_and_out[count.index]}"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.teamserver.public_ip}/32"
  ]
  from_port = 22
  to_port = 22
}
