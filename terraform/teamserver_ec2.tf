# The bastion EC2 instance
resource "aws_instance" "teamserver" {
  ami = "${data.aws_ami.teamserver.id}"
  instance_type = "t2.micro"
  # ebs_optimized = true
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  security_groups = [
    "${aws_security_group.teamserver.name}"
  ]

  user_data = "${data.template_cloudinit_config.ssh_cloud_init_tasks.rendered}"

  tags = "${merge(var.tags, map("Name", "PCA Teamserver"))}"
  volume_tags = "${merge(var.tags, map("Name", "PCA Teamserver"))}"
}
