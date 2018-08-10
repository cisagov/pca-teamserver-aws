# The teamserver AMI
data "aws_ami" "teamserver" {
  filter {
    name = "name"
    values = [
      "pca-teamserver-hvm-*-x86_64-ebs"
    ]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["${data.aws_caller_identity.current.account_id}"] # This is us
  most_recent = true
}
