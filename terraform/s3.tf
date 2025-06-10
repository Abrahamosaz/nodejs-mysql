resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "nodejs-bucket-abraham12342"

  tags = {
    Name        = "Nodejs terraform bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("../public/images", "**")
  key    = "images/${each.key}"
  source = "../public/images/${each.key}"
}