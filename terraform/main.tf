terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_elastic_beanstalk_application" "application" {  
  name = "lavagna"
  description = "Java 8 application \"lavagna\""
}

# data "archive_file" "bundle" {
#   type        = "jar"
#   source_dir  = "./Build"
#   output_path = "bundle.jar"
# }

resource "aws_s3_bucket" "bucket" {
  bucket = "lavagna-app-bucket"
}

resource "aws_s3_object" "bucket_object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "beanstalk/bundle.war"
  # source = data.archive_file.bundle.output_path
  source = "./Build/lavagna-jetty-console.war"
}

resource "aws_elastic_beanstalk_application_version" "name" {
  name        = "test-version"
  application = aws_elastic_beanstalk_application.application.name
  bucket      = aws_s3_bucket.bucket.bucket
  key         = aws_s3_object.bucket_object.key
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
    namespace = "aws:elb:listener:8080"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }
  setting {
    namespace = "aws:elb:listener:8080"
    name      = "InstancePort"
    value     = "8080"
  }
  setting {
    namespace = "aws:elb:listener:8080"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }
  setting {
    namespace = "aws:elb:listener:8080"
    name      = "ListenerEnabled"
    value     = "true"
  }
}
