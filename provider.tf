# Provider Block
provider "aws" {
  //profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Team        = "Cloud-Architect-Group"
      Environment = terraform.workspace
      Location    = "Frisco TX"
    }
  }
  /*
  # Declaring AssumeRole
  assume_role {
    # The Role ARN is the Amazon Resource Name of IAM Role for the Terraform CLI to Assume
    role_arn = var.role_arn
    # Declaring a STS session name
    session_name = var.session_name
  }
  */
}
