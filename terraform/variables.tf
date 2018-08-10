variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default = "us-east-1"
}

variable "aws_availability_zone" {
  description = "The AWS availability zone to deploy into (e.g. a, b, c, etc.)."
  default = "a"
}

variable "tags" {
  type = "map"
  description = "Tags to apply to all AWS resources created"
  default = {}
}

# This should be overridden by a production.tfvars file,
# most-likely stored outside of version control
variable "trusted_ingress_networks_ipv4" {
  type = "list"
  description = "IPv4 CIDR blocks from which to allow ingress to the bastion server"
  default = [ "0.0.0.0/0" ]
}

variable "trusted_ingress_networks_ipv6" {
  type = "list"
  description = "IPv6 CIDR blocks from which to allow ingress to the bastion server"
  default = [ "::/0" ]
}

variable "remote_ssh_user" {
  description = "The username to use when sshing to the EC2 instances"
}
