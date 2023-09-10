terraform {
 # required_version = "~> 1.2"    --??
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
         }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
<<<<<<< HEAD
  access_key = ""
  secret_key = ""
=======
  access_key = "AKIA6K7IQLMRO7YU6DGW"
  secret_key = "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"
>>>>>>> a2d2eac (added files)
}

