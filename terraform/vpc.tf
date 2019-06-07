# The PCA teamserver VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.14.0/24"
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      "Name" = "PCA VPC"
    },
  )
}

# Public subnet of the VPC
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.14.0/24"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    var.tags,
    {
      "Name" = "PCA Public Subnet"
    },
  )
}

# The internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "PCA IGW"
    },
  )
}

# Default route table
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = merge(
    var.tags,
    {
      "Name" = "PCA"
    },
  )
}

# Route all external traffic through the internet gateway
resource "aws_route" "route_external_traffic_through_internet_gateway" {
  route_table_id         = aws_default_route_table.default_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ACL for the public subnet of the VPC
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.public.id,
  ]

  tags = merge(
    var.tags,
    {
      "Name" = "PCA Public Subnet ACL"
    },
  )
}
