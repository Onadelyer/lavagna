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

resource "aws_subnet" "beanstalk_subnet" {
  vpc_id            = aws_vpc.beanstalk_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "beanstalk_subnet-2" {
  vpc_id            = aws_vpc.beanstalk_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table_association" "beanstalk_subnet_association" {
  subnet_id      = aws_subnet.beanstalk_subnet.id
  route_table_id = aws_route_table.beanstalk_route_table.id
}

resource "aws_route_table_association" "beanstalk_subnet_association-2" {
  subnet_id      = aws_subnet.beanstalk_subnet-2.id
  route_table_id = aws_route_table.beanstalk_route_table.id
}