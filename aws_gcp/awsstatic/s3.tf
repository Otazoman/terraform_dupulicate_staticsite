data "aws_iam_policy_document" "cloudfront-logging-bucket" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}-cloudfront-logs",
      "arn:aws:s3:::${var.bucket_name}-cloudfront-logs/*"
    ]
  }
}

resource "aws_s3_bucket" "cloudfront-logging" {
  bucket = "${var.bucket_name}-cloudfront-logs"
}

resource "aws_s3_bucket_public_access_block" "cloudfront-logging-access" {
  bucket                  = aws_s3_bucket.cloudfront-logging.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "cloudfront-logging-ownership" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "cloudfront-logging" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  policy = data.aws_iam_policy_document.cloudfront-logging-bucket.json
}

resource "aws_s3_bucket_request_payment_configuration" "cloudfront-logging-payment" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  payer  = "BucketOwner"
}

resource "aws_s3_bucket_acl" "cloudfront-logging-acl" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  acl    = "private"
}


resource "aws_s3_bucket" "website-logs" {
  bucket = "${var.bucket_name}-logs"
  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_public_access_block" "web-site-logs-access" {
  bucket                  = aws_s3_bucket.website-logs.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "web-site-logs-ownership" {
  bucket = aws_s3_bucket.website-logs.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "web-site-logs-acl" {
  bucket = aws_s3_bucket.website-logs.id
  acl    = "log-delivery-write"
}


resource "aws_s3_bucket" "static-site" {
  bucket = var.bucket_name
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_policy" "static-site-policy" {
  bucket = aws_s3_bucket.static-site.id
  policy = data.aws_iam_policy_document.static-site-bucket_policy.json
}

resource "aws_s3_bucket_versioning" "static-site-versioning" {
  bucket = aws_s3_bucket.static-site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "static-site-logging" {
  bucket        = aws_s3_bucket.static-site.id
  target_bucket = aws_s3_bucket.website-logs.bucket
  target_prefix = "${var.bucket_name}/"
}

resource "aws_s3_bucket_public_access_block" "static-site-access" {
  bucket                  = aws_s3_bucket.static-site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static-site-ownership" {
  bucket = aws_s3_bucket.static-site.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "static-site-acl" {
  bucket = aws_s3_bucket.static-site.id
  acl    = "private"
}

locals {
  s3-origin-id-static-site = "s3-origin-id-static-site"
}

data "aws_iam_policy_document" "static-site-bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.static-site-dst.arn]
    }
  }
}
