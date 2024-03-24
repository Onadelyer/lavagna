resource "aws_vpc" "beanstalk_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "beanstalk_igw" {
  vpc_id = aws_vpc.beanstalk_vpc.id
}

resource "aws_route_table" "beanstalk_route_table" {
  vpc_id = aws_vpc.beanstalk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.beanstalk_igw.id
  }
}