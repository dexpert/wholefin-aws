
resource "aws_s3_bucket" "dev_wholefin_ai" {
  bucket = "dev.wholefin.ai"

  tags = {
    Name = "dev.wholefin.ai"
  }
}

resource "aws_s3_bucket" "wholefin_platform_dev" {
  bucket = "wholefin-platform-dev"

  tags = {
    Name = "wholefin-platform-dev"
  }
}

resource "aws_s3_bucket" "wholefin_platform_documents_dev" {
  bucket = "wholefin-platform-documents-dev"

  tags = {
    Name = "wholefin-platform-documents-dev"
  }
}
