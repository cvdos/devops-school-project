# SET PROVIDER - AMAZON WEB SERVICES
provider "aws" {
  region = "${var.aws-region}"
}
# CREATE VPC
resource "aws_vpc" "dos-vpc" {
  cidr_block       = "${var.vpc-cidr}"
  instance_tenancy = "default"
  tags = {
    Name = "dos-vpc"
  }
}
# CREATE SUBNETS
# List available availability zone names
data "aws_availability_zones" "available" {
  state = "available"
}
# subnets for availability zone eu-west-3a
resource "aws_subnet" "dos-subnet-public-a" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 1)}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "dos-subnet-public-A"
  }
}
resource "aws_subnet" "dos-subnet-private-a" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 2)}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "dos-subnet-private-A"
  }
}
resource "aws_subnet" "dos-subnet-db-a" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 3)}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "dos-subnet-db-A"
  }
}
# subnets for availability zone eu-west-3b
resource "aws_subnet" "dos-subnet-public-b" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 4)}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "dos-subnet-public-B"
  }
}
resource "aws_subnet" "dos-subnet-private-b" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 5)}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "dos-subnet-private-B"
  }
}
resource "aws_subnet" "dos-subnet-db-b" {
  vpc_id                  = "${aws_vpc.dos-vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc-cidr, 8, 6)}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "dos-subnet-db-B"
  }
}
# CREATE GATEWAYS
# elastic IP allocation
resource "aws_eip" "dos-eip-nat" {
  tags = {
    Name = "dos-eip-nat"
  }
}
# internet gateway
resource "aws_internet_gateway" "dos-igw" {
  vpc_id = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-igw"
  }
}
# NAT gateway
resource "aws_nat_gateway" "dos-nat" {
  allocation_id = "${aws_eip.dos-eip-nat.id}"
  subnet_id     = "${aws_subnet.dos-subnet-public-a.id}"
  depends_on    = ["aws_internet_gateway.dos-igw"]
  tags = {
    Name = "dos-NAT"
  }
}
# CREATE ROUTING
# create route tables for public, private and database subnets
resource "aws_route_table" "dos-routetb-public" {
  vpc_id = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-public-route-table"
  }
}
resource "aws_route_table" "dos-routetb-private" {
  vpc_id = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-private-route-table"
  }
}
resource "aws_route_table" "dos-routetb-db" {
  vpc_id = "${aws_vpc.dos-vpc.id}"
  tags = {
    Name = "dos-db-route-table"
  }
}
# create routing rules for public and private subnets
resource "aws_route" "dos-public-route" {
  route_table_id         = "${aws_route_table.dos-routetb-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dos-igw.id}"
}
resource "aws_route" "dos-private-route" {
  route_table_id         = "${aws_route_table.dos-routetb-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.dos-nat.id}"
}
# associate route tables with subnets
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = "${aws_subnet.dos-subnet-public-a.id}"
  route_table_id = "${aws_route_table.dos-routetb-public.id}"
}
resource "aws_route_table_association" "private-subnet-association" {
  subnet_id      = "${aws_subnet.dos-subnet-private-a.id}"
  route_table_id = "${aws_route_table.dos-routetb-private.id}"
}
resource "aws_route_table_association" "db-subnet-association" {
  subnet_id      = "${aws_subnet.dos-subnet-db-a.id}"
  route_table_id = "${aws_route_table.dos-routetb-db.id}"
}
# VPC's main routing table fallback
resource "aws_main_route_table_association" "set-main-routetb" {
  vpc_id         = "${aws_vpc.dos-vpc.id}"
  route_table_id = "${aws_route_table.dos-routetb-public.id}"
}
