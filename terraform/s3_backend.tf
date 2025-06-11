variable "bucket_name" {
    type = string
    default = "mystatebucket12232"
}


data "aws_iam_user" "Abraham" {
    user_name = "Abraham"
}

resource "aws_s3_bucket" "mystate_bucket" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_versioning" "mystate-bucket-versioning" {
  bucket = aws_s3_bucket.mystate_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket =  aws_s3_bucket.mystate_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_iam_account.json
}


data "aws_iam_policy_document" "allow_access_from_iam_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.Abraham.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.mystate_bucket.arn,
      "${aws_s3_bucket.mystate_bucket.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_public_access_block" "mystate_bucket_public_access_block" {
  bucket = aws_s3_bucket.mystate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}