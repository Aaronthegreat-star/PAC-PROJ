# terraform {
# #   backend "s3" {
# #     bucket = "api-terraform-state-file-bucket"
# #     key = "terraform/state/terraform.tfstate"
# #     region = "us-east-1"
# #     dynamodb_table = "terraform-state-lock"
# #     encrypt = true
# #   }
# # }

terraform {
    backend "remote" {
        organization = "Aaronhood"

        workspaces {
            name = "PAC-PROJ"
        }
    }
}
# resource "aws_s3_bucket" "terraform_state" {
#    bucket = "api-terraform-state-file-bucket"
# #    region = "us-east-1"
# }