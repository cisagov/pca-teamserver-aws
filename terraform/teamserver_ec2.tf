# The teamserver EC2 instance
locals {
  tags = merge(
    var.tags,
    {
      "Name"           = "PCA Teamserver"
      "Publish Egress" = "True"
    },
  )
}

# The Elastic IPs for the teamserver
resource "aws_eip" "teamserver_eip" {
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name"           = "PCA Teamserver EIP"
      "Publish Egress" = "True"
    },
  )
}

# The teamserver EC2 instance
resource "aws_instance" "teamserver" {
  ami           = data.aws_ami.teamserver.id
  instance_type = "t3.medium"

  # ebs_optimized = true
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  # This is the public subnet of the VPC
  subnet_id = aws_subnet.public.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.teamserver.id,
  ]

  user_data_base64 = data.cloudinit_config.teamserver_cloud_init_tasks.rendered

  tags        = local.tags
  volume_tags = local.tags
}

# The EIP association for the teamserver
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.teamserver.id
  allocation_id = aws_eip.teamserver_eip.id
}

# Extra volume for storing PCA data that we want to be immortal.  I
# use the prevent_destroy lifecycle element to disallow the
# destruction of this volume via terraform.
#
# This volume eventually gets mounted at /opt/PCA.
resource "aws_ebs_volume" "teamserver_data" {
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  type              = "io1"
  size              = 10
  iops              = 100
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "teamserver_data_attachment" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.teamserver_data.id
  instance_id = aws_instance.teamserver.id
}
