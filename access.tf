 provider "aws" {
   access_key = var.access_key
   secret_key = var.aws_secret_access_key
   region     = var.aws_region
 }

#provider "aws" {
#    profile = "sandbox-ics"
#    region = var.aws_region
#}