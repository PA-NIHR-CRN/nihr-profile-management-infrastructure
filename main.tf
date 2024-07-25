terraform {
  backend "s3" {
    region  = "eu-west-2"
    encrypt = true
  }

}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "profile_management_ecr" {
  source    = "github.com/PA-NIHR-CRN/terraform-modules//ecr?ref=v1.0.0"
  repo_name = "${var.names["${var.env}"]["accountidentifiers"]}-${var.env}-${var.names["system"]}-ecr-repository"
  env       = var.env
  app       = var.names["${var.env}"]["app"]
  account   = var.names["${var.env}"]["accountidentifiers"]
  system    = var.names["system"]
}