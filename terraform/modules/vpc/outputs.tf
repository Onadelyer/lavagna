output "public-subnets" {
  value = [aws_subnet.beanstalk_subnet.id, aws_subnet.beanstalk_subnet-2.id]
}

output "vpc-id" {
  value = aws_vpc.beanstalk_vpc.id
}