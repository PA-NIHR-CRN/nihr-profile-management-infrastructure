provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      System = "rddi-profile-management"
    }
  }
}