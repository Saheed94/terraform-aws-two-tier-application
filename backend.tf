terraform {
  backend "s3" {
    bucket = "hug-lagos-ibadan-terraform-state-saheed-2026"
    key    = "week3/terraform.tfstate"
    region = "eu-west-2"

    encrypt = true
  }
}