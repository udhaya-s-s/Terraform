terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

data "aws_default_vpc" "default" {}

resource "aws_security_group" "udhaya_sg" {
  name        = "udhaya_sg"
  description = "Allow ssh and https"
  vpc_id      = data.aws_vpc.default.id



    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

 ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

     ingress {
    description      = "Jenkins web UI access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow from anywhere; restrict for production!
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }


    tags = {
    Name = "udhaya_sg"
  }
}

  
resource "aws_instance" "Jenkins_master" {
  ami           = "ami-0f918f7e67a3323f0" # ap-south-1
  instance_type = "t2.micro"
  key_name     = "m4_23_05"
  vpc_security_group_id = [aws_security_group.udhaya_sg.id]

  root_block_device {
    volume_size = 15
    volume_type = "gp2"

    tags ={
        name = "jenkins_instance_volume"
    }
  }

  tags = {
    name = "enkins_master"
  }
}