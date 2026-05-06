terraform {
  backend "s3" {
    bucket         = "wholefin-tfstate-sand-844486820647"
    key            = "sand/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "wholefin-tfstate-lock"
    encrypt        = true
  }
}
