provider "aws" {
  region = "ap-south-1"
}

# Create S3 bucket
resource "aws_s3_bucket" "static_website" {
  bucket = "sumeet-static-website-2025"
}

# Allow public access by disabling block public access
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure static website hosting
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Upload website files
resource "aws_s3_object" "website_files" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "index.html"
  source       = "./website/index.html"  # Make sure this file exists
  content_type = "text/html"
}

# Public bucket policy
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# Optional: Output the S3 website endpoint
output "website_url" {
  value = aws_s3_bucket.static_website.website_endpoint
}