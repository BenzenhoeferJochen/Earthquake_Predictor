terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "us-west-2"
  shared_credentials_files = ["credentials"]
}

data "http" "myip" {
  url = "https://ipinfo.io/ip"
}

data "aws_ssm_parameter" "AL2023AMISSM" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
