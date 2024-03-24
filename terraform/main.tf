terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {  
  region = "us-east-1"
}

#CREATING VPC, GATEWAY AND ROUTE TABLE FOR ALL SUBNETS
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

#CREATING SUBNETS AND UNION THEM IN GROUPS
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

resource "aws_db_subnet_group" "lavagna-subnet-group" {
  name = "lavagna-db-subnet-group"
  subnet_ids = [ aws_subnet.beanstalk_subnet.id, aws_subnet.beanstalk_subnet-2.id]
}

resource "aws_route_table_association" "beanstalk_subnet_association" {
  subnet_id      = aws_subnet.beanstalk_subnet.id
  route_table_id = aws_route_table.beanstalk_route_table.id
}

resource "aws_security_group" "lavagna-security-group" {
  name = "lavagna-security-group"
  vpc_id = aws_vpc.beanstalk_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elastic_beanstalk_application" "application" {  
  name = "lavagna"
  description = "Java 8 application \"lavagna\""
}

data "archive_file" "bundle" {
  type        = "zip"
  source_dir  = "./Build"
  output_path = "bundle.zip"
}

resource "aws_db_instance" "demobank_rds_pgsql" {
  identifier             = "lavagna-db"
  db_name                = "lavagna"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "12.12"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.lavagna-subnet-group.name
  vpc_security_group_ids = [aws_security_group.lavagna-security-group.id]
  username               = "myuser"
  password               = "mypassword"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lavagna-app-bucket"
}

resource "aws_s3_object" "bucket_object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "beanstalk/bundle.zip"
  source = data.archive_file.bundle.output_path
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
    name      = "AssociatePublicIpAddress"
    namespace = "aws:ec2:vpc"
    value     = "True"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.beanstalk_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.beanstalk_subnet.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.lavagna-security-group.id
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
    value     = "jdbc:postgresql://${aws_db_instance.demobank_rds_pgsql.address}:5432/${aws_db_instance.demobank_rds_pgsql.db_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.username"
    value     = aws_db_instance.demobank_rds_pgsql.username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "datasource.password"
    value     = aws_db_instance.demobank_rds_pgsql.password
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
