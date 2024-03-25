resource "aws_elastic_beanstalk_application" "application" {  
  name = "lavagna"
  description = "Java 8 application \"lavagna\""
}

resource "aws_elastic_beanstalk_application_version" "name" {
  name        = "test-version"
  application = aws_elastic_beanstalk_application.application.name
  bucket      = var.bucket
  key         = var.bucket-key
}

resource "aws_elastic_beanstalk_environment" "name" {
  name                = "lavagna-env"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v4.4.1 running Tomcat 9 Corretto 8"
  version_label = aws_elastic_beanstalk_application_version.name.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    name      = "AssociatePublicIpAddress"
    namespace = "aws:ec2:vpc"
    value     = "True"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc-id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [var.public-subnets[0], var.public-subnets[1]])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [var.public-subnets[0], var.public-subnets[1]])
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.beanstalk-instance-sg
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = var.lb-security-group
  }

  # Environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.dialect"
    value     = "PGSQL"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.url"
    value     = "jdbc:postgresql://${var.rds-endpoint}/${var.rds-db-name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.username"
    value     = var.rds-db-username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.password"
    value     = var.rds-db-password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "spring.profile.active"
    value     = "dev"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "test-key-pair"
  }
}
