## downsync bucket & acl
resource "aws_s3_bucket" "downsync" {
  bucket = "${var.source_prefix}-${var.downsync_bucket_name}"
}

resource "aws_s3_bucket_acl" "downsync_acl" {
  bucket = aws_s3_bucket.downsync.id
  acl    = "private"
}

## ensure that accidental public access to the downsync bucket does not happen
resource "aws_s3_bucket_public_access_block" "downsync_acl_block" {
  bucket                  = aws_s3_bucket.downsync.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### scrubbing bucket & acl
resource "aws_s3_bucket" "scrub_scripts" {
  bucket = "${var.source_prefix}-${var.scrub_bucket_name}"

  tags = {
    Name      = var.scrub_bucket_name
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_acl" "scrub_scripts_acl" {
  bucket = aws_s3_bucket.scrub_scripts.id
  acl    = "private"
}

### ensure that accidental public access to the scrub bucket does not happen
resource "aws_s3_bucket_public_access_block" "scrub_acl_block" {
  bucket                  = aws_s3_bucket.scrub_scripts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
