terraform {
  backend "s3" {
    bucket = "api-terraform-state-file"
    key = "terraform/state/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }

  backend "remote" {
     hostname = "app.terraform.io"
        organization = "Aaronhood"

    workspaces {
        name = "PAC-PROJ"
        }
    }
}

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "api-terraform-state-file-bucket"
#   region = "us-east-1"
# }