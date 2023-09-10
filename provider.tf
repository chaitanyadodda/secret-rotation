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
  access_key = ""
  secret_key = ""
>>>>>>> a2d2eac (added files)
}

