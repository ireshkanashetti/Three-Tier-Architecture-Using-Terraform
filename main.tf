terraform {
  backend "s3" {
  bucket ="my-bucket-3-tier"
  key = "jenkin"
  region = "eu-north-1" 
    
  }
}

# provider
provider "aws" {
  region = var.region
}

# create vpc
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name ="${var.project-name}-vpc"
  }
}

# create private subnet
resource "aws_subnet" "private-subnet1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private-sub1-cidr
  availability_zone = var.az1
  tags = {
    Name="${var.project-name}-private-subnet1"
  }
}
resource "aws_subnet" "private-subnet2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private-sub2-cidr
  availability_zone = var.az2
  tags = {
    Name="${var.project-name}-private-subnet2"
  }
}

# create a public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.public-sub-cidr
  availability_zone = var.az3
  map_public_ip_on_launch = true
  tags = {
    Name ="${var.project-name}-public-sub"
  }
}

# create a internet-getway
resource "aws_internet_gateway" "my-IG" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name ="${var.project-name}-my-IG"
  }
}

# create a eip
resource "aws_eip" "my-nat-eip" {
  domain = "vpc"
  tags = {
    Name="${var.project-name}-nat-eip"
  }
}

# create a nat-gateway
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.my-nat-eip.id
  subnet_id = aws_subnet.public-subnet.id
  tags = {
    Name="${var.project-name}-nat-gateway"
  }
}

# create a default route-table
resource "aws_default_route_table" "main-RT" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
  tags = {
    Name="${var.project-name}-main-RT"
  }
}

# add route in main route-table
resource "aws_route" "aws_route" {
  route_table_id = aws_default_route_table.main-RT.id
  destination_cidr_block = var.igw-cidr
  gateway_id = aws_internet_gateway.my-IG.id
}

# create a private(own) route-table
resource "aws_route_table" "aws_route-own" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name="${var.project-name}private-RT"
  }
}

# add route-table association
resource "aws_route_table_association" "private-asso-1" {
  subnet_id = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.aws_route-own.id
}
resource "aws_route_table_association" "private-asso-2" {
  subnet_id = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.aws_route-own.id
}

# add route-table association to nat-gateway
resource "aws_route" "private-sub-nat-route" {
  route_table_id = aws_route_table.aws_route-own.id
  destination_cidr_block = var.nat-cidr
  nat_gateway_id = aws_nat_gateway.my-nat.id
}

# create security group
resource "aws_security_group" "my-SG" {
  vpc_id = aws_vpc.my-vpc.id
  name = "${var.project-name}-my-SG"
  description = "allow ssh, http, mysql traffic"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [ aws_vpc.my-vpc ]
}

# create public server
resource "aws_instance" "public-server" {
  subnet_id = aws_subnet.public-subnet.id
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.my-SG.id]
  tags = {
    Name="${var.project-name}-web-server"
  }
  depends_on = [ aws_security_group.my-SG ]
}

# create private server
resource "aws_instance" "private-server" {
  subnet_id = aws_subnet.private-subnet1.id
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.my-SG.id]
  tags = {
    Name="${var.project-name}-app-server"
  }
  depends_on = [ aws_security_group.my-SG ]
}