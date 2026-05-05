resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "actions_web_bucket" {
  bucket = "${var.project}-${var.environment}-web-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_website_configuration" "actions_web_bucket" {
  bucket = aws_s3_bucket.actions_web_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "actions_web_bucket" {
  bucket = aws_s3_bucket.actions_web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "actions_web_bucket" {
  bucket = aws_s3_bucket.actions_web_bucket.id
  policy = data.aws_iam_policy_document.actions_web_bucket.json

# # Public Access Blockを先に設定しないとBucket PolicyがAWS側で拒否されるため順序を明示
  depends_on = [
    aws_s3_bucket_public_access_block.actions_web_bucket
  ]
}

data "aws_iam_policy_document" "actions_web_bucket" {
  statement {
    sid       = "AllowPublicRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.actions_web_bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}