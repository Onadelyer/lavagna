output "bucket" {
  value = aws_s3_bucket.bucket.bucket
}

output "bucket-key" {
  value = aws_s3_object.bucket_object.key
}