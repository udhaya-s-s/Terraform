terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "udhaya-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "udhaya-vpc"
  }
}

#creating public subnet

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.udhaya-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my-vpc-pub-sub"
  }
}

#creating private subnet

resource "aws_subnet" "prisub" {
  vpc_id     = aws_vpc.udhaya-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "my-vpc-pri-sub"
  }
}

#creating internet gateway

resource "aws_internet_gateway" "tfgw" {
  vpc_id = aws_vpc.udhaya-vpc.id

  tags = {
    Name = "my-vpc-igw"
  }
}

#creating public route table

resource "aws_route_table" "pubroutetable" {
  vpc_id = aws_vpc.udhaya-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfgw.id
  }

  tags = {
    Name = "my-vpc-pub-route-table"
  }
}

#associating subnet and route table

resource "aws_route_table_association" "pubrtasso" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubroutetable.id
}

#we need elastic ip for nat gateway

resource "aws-eip" "myeip" {
  vpc = true
}

#NAT gateway

resource "aws_nat_gateway" "tfnat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "my-vpc-nat"
  }
}

#private route table

resource "aws_route_table" "priroutetable" {
  vpc_id = aws_vpc.udhaya-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tfnat.id
  }

  tags = {
    Name = "my-vpc-pri-route-table"
  }
}

#associating subnet and route table

resource "aws_route_table_association" "prirtasso" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.priroutetable.id
}

#security_group

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.udhaya-vpc.id

  tags = {
    Name = "udhaya-vpc-sg"
  }

ingress 
{
  description        = "TLS from vpc"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_block = ["0.0.0.0/0"]
 
}

ingress 
{
  description        = "TLS from vpc"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_block = ["0.0.0.0/0"]
 
}

egress 
{
  description        = "TLS from vpc"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_block = ["0.0.0.0/0"]
  ipv6_cidr_block = ["::/0"]
 
}
}

resource "aws_instance" "instance_1_pubsub" {
  ami           = "ami-0d03cb826412c6b0f "
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.pubsub.id
  vpc_security_group_id = [aws_security_group.allow_all.id]
  key_name = "m4_23_05"
  associate_public_ip_address = true

  tags = {
    Name = "instance_1_public_subnet"
  }
}

resource "aws_instance" "instance_2_Prisub" {
  ami           = "ami-0d03cb826412c6b0f "
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.prisub.id
  vpc_security_group_id = [aws_security_group.allow_all.id]
  key_name = "m4_23_05"
  associate_public_ip_address = true

  tags = {
    Name = "instance_1_public_subnet"
  }
}

