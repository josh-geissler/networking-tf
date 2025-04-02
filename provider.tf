terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
  }
  backend "s3" {
    bucket = "geissler-homelab" 
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
}