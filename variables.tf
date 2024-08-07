variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


variable "aws_vpc_name" {
  type    = string
  default = "my-tf-vpc"
}

variable "aws_publicSubnet_name" {
  type    = string
  default = "tf-PublicSubnet"
}

variable "aws_publicSubnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "aws_igw_name" {
    type = string
    default = "tf-igw"
  
}

variable "aws_ec2_instancetype" {
  type    = string
  default = "t2.micro"
}

variable "aws_ec2_instanceami" {
  type    = string
  default = "ami-00060fac2f8c42d30"
}


variable "aws_ec2_instancename" {
  type    = string
  default = "my-tf-ec2-instance"
}
