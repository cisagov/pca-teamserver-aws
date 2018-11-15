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
  instance_type = "t3.medium"
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

  user_data = "${data.template_cloudinit_config.teamserver_cloud_init_tasks.rendered}"

  tags = "${local.tags}"
  volume_tags = "${local.tags}"
}

# The EIP association for the teamserver
resource "aws_eip_association" "eip_assoc" {
  instance_id = "${aws_instance.teamserver.id}"
  allocation_id = "${aws_eip.teamserver_eip.id}"
}

# Provision the teamserver EC2 instance via Ansible
module "teamserver_ansible_provisioner" {
  source = "github.com/cloudposse/tf_ansible"

  arguments = [
    "--user=${var.remote_ssh_user}",
    "--ssh-common-args='-o StrictHostKeyChecking=no'"
  ]
  envs = [
    "host=${aws_eip.teamserver_eip.public_ip}",
    "host_groups=cobaltstrike",
  ]
  playbook = "../ansible/playbook.yml"
  dry_run = false
}

# Extra volume for storing PCA data that we want to be immortal.  I
# use the prevent_destroy lifecycle element to disallow the
# destruction of this volume via terraform.
#
# This volume eventually gets mounted at /opt/PCA.
resource "aws_ebs_volume" "teamserver_data" {
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  type = "io1"
  size = 10
  iops = 100
  encrypted = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "teamserver_data_attachment" {
  device_name = "/dev/xvdb"
  volume_id = "${aws_ebs_volume.teamserver_data.id}"
  instance_id = "${aws_instance.teamserver.id}"

  # Terraform attempts to destroy the volume attachments before it
  # attempts to destroy the EC2 instance they are attached to.  EC2
  # does not like that and it results in the failed destruction of the
  # volume attachments.  To get around this, we explicitly terminate
  # the instance via the AWS CLI in a destroy provisioner; this
  # gracefully shuts down the instance and allows terraform to
  # successfully destroy the volume attachments.
  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region=${var.aws_region} ec2 terminate-instances --instance-ids ${aws_instance.teamserver.id}"
    on_failure = "continue"
  }

  # Wait until instance is terminated before continuing on
  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region=${var.aws_region} ec2 wait instance-terminated --instance-ids ${aws_instance.teamserver.id}"
  }

  skip_destroy = true
}
