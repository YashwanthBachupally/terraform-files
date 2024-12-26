resource "aws_s3_bucket" "app" {
  bucket = "${var.environment}-${var.bucket_name}"

  tags = {
    Name        = "${var.environment}-${var.bucket_name}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}