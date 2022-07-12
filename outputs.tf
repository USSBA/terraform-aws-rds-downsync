output "downsync" {
  value = aws_s3_bucket.downsync
}

output "scrub_scripts" {
  value = aws_s3_bucket.scrub_scripts
}

output "source_security_group" {
  value = aws_security_group.source
}

output "target_security_group" {
  value = aws_security_group.target
}
