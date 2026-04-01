output "ALB_DNS_Name" {
  value = aws_lb.KiQ-ALB.dns_name
}

output "RDS_EndPoint" {
  value = aws_db_instance.KiQ_db.endpoint
}

output "Bucket_id" {
  value = aws_s3_bucket.KiQ_s3_bucket.bucket
}