# The teamserver EC2 instance
locals {
  tags = "${merge(var.tags, map("Name", "PCA Teamserver", "Publish Egress", "True"))}"
}

# The Elastic IPs for the teamserver
resource "aws_eip" "teamserver_eip" {
  vpc = true
  tags = "${merge(var.tags, map("Name", "PCA Teamserver EIP", "Publish Egress", "True"))}"
}

# The teamserver EC2 instance
resource "aws_instance" "teamserver" {
  ami = "${data.aws_ami.teamserver.id}"
  instance_type = "t2.medium"
  # ebs_optimized = true
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  # This is the public subnet of the VPC
  subnet_id = "${aws_subnet.public.id}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.teamserver.id}"
  ]

  user_data = "${data.template_cloudinit_config.ssh_cloud_init_tasks.rendered}"

  tags = "${local.tags}"
  volume_tags = "${local.tags}"
}

# The EIP association for the teamserver
resource "aws_eip_association" "eip_assoc" {
  instance_id = "${aws_instance.teamserver.id}"
  allocation_id = "${aws_eip.teamserver_eip.id}"
}
