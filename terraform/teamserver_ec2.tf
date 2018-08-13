# The bastion EC2 instance
locals {
  tags = "${merge(var.tags, map("Name", "PCA Teamserver"))}"
}

resource "aws_instance" "teamserver" {
  ami = "${data.aws_ami.teamserver.id}"
  instance_type = "t2.micro"
  # ebs_optimized = true
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  # This is the public subnet of the VPC
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.teamserver.id}"
  ]

  user_data = "${data.template_cloudinit_config.ssh_cloud_init_tasks.rendered}"

  tags = "${local.tags}"
  volume_tags = "${local.tags}"
}
