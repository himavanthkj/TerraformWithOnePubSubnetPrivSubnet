provider "aws" {
  region = "us-east-1"
}

#Getting azs
data "aws_availability_zones" "azs" {
  state = "available"
}
resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/16"
  tags  = {
      Name  = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.web_vpc.id
  availability_zone = data.aws_availability_zones.azs.names
}

resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.web_vpc.id
  ingress
      {
          description = "TLS from VPC"
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = [aws_vpc.web_vpc.cidr_block]
      }
  egress
      {
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0"]
      }
    tags = {
      Name = "allow_tls"
  }
}   

data "aws_ami" "my_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "web_app" {
  count = 4
  ami  = data.aws_ami.my_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id = aws_subnet.public_subnet.id
}