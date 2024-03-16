resource "aws_elastic_beanstalk_application" "beanstalk_application" {
    name = "lavagna"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_environment" {
    name = "lavagna_environment"
    application = aws_elastic_beanstalk_application.beanstalk_application
    solution_stack_name = "64bit Amazon Linux 2 v3.1.4 running Java 8 Corretto"
    description = "Environment for Java8 application \"lavagna\""
}