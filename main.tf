terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    Name = var.aws_vpc_name
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = var.aws_publicSubnet_cidr

  tags = {
    Name = var.aws_publicSubnet_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = var.aws_igw_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # all requests will be routed to internet gateway as this is route table of the public subnet.
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "publicSubnet-routetable"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public_ec2_sg" {
  name        = "public-ec2-sg"
  description = "This allows EC2 instance to have SSH and HTTP connections"
  vpc_id      = aws_vpc.tf_vpc.id
  tags = {
    Name = "PublicEC2Sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_ec2_sg.id

  cidr_ipv4   = "0.0.0.0/0" # any incoming request needs to be handled by EC2
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


# not safety as it accepts any incoming SSH requests from anyone
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_ec2_sg.id

  cidr_ipv4   = "0.0.0.0/0" # any incoming request needs to be handled by EC2
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.public_ec2_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = -1
  to_port     = 0 
}

resource "aws_instance" "public_ec2" {
  ami           = var.aws_ec2_instanceami
  instance_type = var.aws_ec2_instancetype
  tags = {
    Name = var.aws_ec2_instancename
  }
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_ec2_sg.id]

  user_data = <<-EOF
  #!/bin/bash -xe
  sudo yum -y install nginx
  echo "<h1>Running through public EC2 instance </h1>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx
  EOF
}

output "instance_public_ip_addr" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.public_ec2.public_ip
}
