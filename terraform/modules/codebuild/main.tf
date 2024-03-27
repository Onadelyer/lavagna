resource "aws_codebuild_project" "name" {
  name          = "lavagna-codebuild"
  build_timeout = 15
  service_role  = "arn:aws:iam::536460581283:role/service-role/cwe-role-us-east-1-devops-pipeline"

  source_version = "test"

  source {
    type            = "GITHUB"
    location        = "https://github.com/Onadelyer/lavagna"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
  }

  artifacts {
    type = "S3"
    packaging = "ZIP"
    location = "lavagna-bucket"
    name = "bundle.zip"
    path = "beanstalk/"
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
  }
}