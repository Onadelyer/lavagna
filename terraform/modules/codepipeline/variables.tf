resource "aws_codepipeline" "my_pipeline" {
  name     = "my-codepipeline"
  role_arn = "arn:aws:iam::123456789012:role/my-codepipeline-role" // Define your IAM role ARN here

  artifact_store {
    location = "lavagna-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = "Onadelyer"
        Repo       = "lavagna"
        Branch     = "test"
        OAuthToken = ""
      }
    }
  }

  stage{
    name = "Build"

    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = "your-codebuild-project-name"
      }
    }
  }

  // Define more stages as needed
}