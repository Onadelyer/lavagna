resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name = "beanstalk-instance-profile"
  role = aws_iam_role.beanstalk_role.name
}

resource "aws_iam_role" "beanstalk_role" {
  name               = "beanstalk-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_policy_attachment" {
  name       = "beanstalk-policy-attachment"
  roles      = [aws_iam_role.beanstalk_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_environment" {
  name                = "lavagna-environment"
  application         = aws_elastic_beanstalk_application.beanstalk_application.name
  solution_stack_name = "64bit Amazon Linux 2 v3.6.4 running Corretto 8"
  description         = "Environment for Java8 application \"lavagna\""
  instance_profile    = aws_iam_instance_profile.beanstalk_instance_profile.name
}
