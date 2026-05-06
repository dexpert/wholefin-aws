
resource "aws_s3_bucket" "dev_wholefin_ai" {
  bucket_prefix = "dev.wholefin.ai-"

  tags = {
    Name = "dev.wholefin.ai"
  }
}

resource "aws_s3_bucket" "wholefin_platform_dev" {
  bucket_prefix = "wholefin-platform-dev-"

  tags = {
    Name = "wholefin-platform-dev"
  }
}

resource "aws_s3_bucket" "wholefin_platform_documents_dev" {
  bucket_prefix = "wholefin-platform-documents-de-"

  tags = {
    Name = "wholefin-platform-documents-dev"
  }
}
