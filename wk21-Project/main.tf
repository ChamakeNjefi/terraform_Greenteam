# Specify the region in which we would want to deploy our stack
variable "region" {
  default = "us-east-1"
}

# Specify 3 availability zones from the region
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default vpc"
  }
}

resource "aws_default_subnet" "default_az" {
  count             = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "default_az-${count.index}"
  }
}

# Create a Security group
resource "aws_security_group" "webserver_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "vpc-01f6de57abadb0d40"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Put an instance in each subnet
resource "aws_instance" "web_server" {
  count                  = length(var.availability_zones)
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = "wk21_keypair"
  subnet_id              = aws_default_subnet.default_az[count.index].id

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo service httpd start
    sudo service httpd enable
    sudo echo "<h1>Welcome to week 21 project</h1>" > /var/www/html/index.html

  EOF

  tags = {
    Name = "web_server-${count.index}"
  }
}


