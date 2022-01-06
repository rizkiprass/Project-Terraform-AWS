# provider "aws" {
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
#   region     = "ap-southeast-1"
# }

provider "aws" {
    profile = "sandbox-ics"
    region = var.aws_region
}