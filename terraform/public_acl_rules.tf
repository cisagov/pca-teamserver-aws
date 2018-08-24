locals {
  # The ports on which only traffic from trusted networks is allowed
  # to ingress
  trusted_ingress_ports = [
    22,
    993,
    50050
  ]

  # The ports on which traffic from untrusted networks is allowed to
  # ingress
  untrusted_ingress_ports = [
    80,
    443,
    25,
    587
  ]

  # The ports on which traffic is allowed to egress
  egress_ports = [
    80,
    443,
    25,
    143,
    587,
    993
  ]

  # Helpful for setting up the ephemeral port rules
  egress = [
    true,
    false
  ]
}

# Allow ingress from anywhere via trusted ports.  The security group
# rules will refine access further to specific, trusted CIDR blocks.
resource "aws_network_acl_rule" "public_trusted_ingress" {
  count = "${length(local.trusted_ingress_ports)}"
  
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "tcp"
  rule_number = "${100 + count.index}"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = "${local.trusted_ingress_ports[count.index]}"
  to_port = "${local.trusted_ingress_ports[count.index]}"
}
resource "aws_network_acl_rule" "public_untrusted_ingress" {
  count = "${length(local.untrusted_ingress_ports)}"
  
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "tcp"
  rule_number = "${150 + count.index}"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = "${local.untrusted_ingress_ports[count.index]}"
  to_port = "${local.untrusted_ingress_ports[count.index]}"
}

# Allow egress anywhere via egress ports
resource "aws_network_acl_rule" "public_egress" {
  count = "${length(local.egress_ports)}"
  
  network_acl_id = "${aws_network_acl.public.id}"
  egress = true
  protocol = "tcp"
  rule_number = "${200 + count.index}"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = "${local.egress_ports[count.index]}"
  to_port = "${local.egress_ports[count.index]}"
}

# Allow egress to and from anywhere via TCP ephemeral ports.  This is
# necessary for the above ingress and egress accesses to work properly.
resource "aws_network_acl_rule" "public_ephemeral_ports" {
  count = "${length(local.egress)}"
  
  network_acl_id = "${aws_network_acl.public.id}"
  egress = "${local.egress[count.index]}"
  protocol = "tcp"
  rule_number = "${300 + count.index}"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}
