# Terraform Block
terraform {
  required_version = ">=1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=3.1.0"
    }
  }

  backend "s3" {
    bucket  = "374278-terraform-tfstate"
    key     = "dev/secrets_manager_pwd_rotation_rds"
    encrypt = "true"
    region  = "us-east-1"
    profile = "tf-admin"
    //role_arn     = "arn:aws:iam::502433561161:role/374278-TerraformRole"
    //session_name = "tf_sts_session"
  }

}
