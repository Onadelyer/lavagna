resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name
}

# resource "aws_s3_object" "bucket_object" {
#   bucket = aws_s3_bucket.bucket.id
#   key    = var.key
#   source = var.bucket-source
# }