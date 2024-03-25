output "elb-security-group-id" {
  value = aws_security_group.beanstalk-elb-sg.id
}

output "instance-security-group-id" {
  value = aws_security_group.beanstalk-instance-sg.id
}

output "rds-security-group-id" {
  value = aws_security_group.rds-sg.id
}
