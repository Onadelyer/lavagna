terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  region = "us-west-2"

  endpoints {
    acm = "http://localhost:4566"
    amplify = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    apigatewayv2 = "http://localhost:4566"
    appconfig = "http://localhost:4566"
    applicationautoscaling = "http://localhost:4566"
    appsync = "http://localhost:4566"
    athena = "http://localhost:4566"
    autoscaling = "http://localhost:4566"
    backup = "http://localhost:4566"
    batch = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
    cloudsearch = "http://localhost:4566"
    cloudtrail = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    codecommit = "http://localhost:4566"
    cognitoidentity = "http://localhost:4566"
    cognitoidp = "http://localhost:4566"
    config = "http://localhost:4566"
    configservice = "http://localhost:4566"
    costexplorer = "http://localhost:4566"
    docdb = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    ecr = "http://localhost:4566"
    ecs = "http://localhost:4566"
    efs = "http://localhost:4566"
    eks = "http://localhost:4566"
    elasticache = "http://localhost:4566"
    elasticbeanstalk = "http://localhost:4566"
    elasticsearch = "http://localhost:4566"
    elb = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
    emr = "http://localhost:4566"
    es = "http://localhost:4566"
    events = "http://localhost:4566"
    firehose = "http://localhost:4566"
    fis = "http://localhost:4566"
    glacier = "http://localhost:4566"
    glue = "http://localhost:4566"
    iam = "http://localhost:4566"
    iot = "http://localhost:4566"
    iotanalytics = "http://localhost:4566"
    iotevents = "http://localhost:4566"
    kafka = "http://localhost:4566"
    kinesis = "http://localhost:4566"
    kinesisanalytics = "http://localhost:4566"
    kinesisanalyticsv2 = "http://localhost:4566"
    kms = "http://localhost:4566"
    lakeformation = "http://localhost:4566"
    lambda = "http://localhost:4566"
    mediaconvert = "http://localhost:4566"
    mediastore = "http://localhost:4566"
    mq = "http://localhost:4566"
    mwaa = "http://mwaa.localhost.localstack.cloud:4566"
    neptune = "http://localhost:4566"
    opensearch = "http://localhost:4566"
    organizations = "http://localhost:4566"
    qldb = "http://localhost:4566"
    rds = "http://localhost:4566"
    redshift = "http://localhost:4566"
    redshiftdata = "http://localhost:4566"
    resourcegroups = "http://localhost:4566"
    resourcegroupstaggingapi = "http://localhost:4566"
    route53 = "http://localhost:4566"
    route53resolver = "http://localhost:4566"
    s3 = "http://s3.localhost.localstack.cloud:4566"
    s3control = "http://localhost:4566"
    sagemaker = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    serverlessrepo = "http://localhost:4566"
    servicediscovery = "http://localhost:4566"
    ses = "http://localhost:4566"
    sesv2 = "http://localhost:4566"
    sns = "http://localhost:4566"
    sqs = "http://localhost:4566"
    ssm = "http://localhost:4566"
    stepfunctions = "http://localhost:4566"
    sts = "http://localhost:4566"
    swf = "http://localhost:4566"
    timestreamwrite = "http://localhost:4566"
    transcribe = "http://localhost:4566"
    transfer = "http://localhost:4566"
    waf = "http://localhost:4566"
    wafv2 = "http://localhost:4566"
    xray = "http://localhost:4566"
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

resource "aws_db_instance" "demobank_rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  identifier             = "javademoapp"
  db_name                = "demobank_db"
  username               = "admin"
  password               = "adminuser"
  parameter_group_name   = "default.mysql8.0"
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.demoapp_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.bank_app_rds_sg.id]
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lavagna-app-bucket"
}

resource "aws_s3_object" "bucket_object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "beanstalk/bundle.war"
  source = data.archive_file.bundle.output_path
  # source = "./Build/lavagna-jetty-console.war"
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
