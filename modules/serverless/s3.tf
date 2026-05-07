
resource "aws_s3_bucket" "wholefin_ai" {
  bucket = "${var.environment}.wholefin.ai"

  tags = {
    Name = "${var.environment}.wholefin.ai"
  }
}

resource "aws_s3_bucket" "wholefin_platform" {
  bucket = "wholefin-platform-${var.environment}"

  tags = {
    Name = "wholefin-platform-${var.environment}"
  }
}

resource "aws_s3_bucket" "wholefin_platform_documents" {
  bucket = "wholefin-platform-documents-${var.environment}"

  tags = {
    Name = "wholefin-platform-documents-${var.environment}"
  }
}
