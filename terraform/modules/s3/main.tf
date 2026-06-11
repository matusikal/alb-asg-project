resource "aws_s3_bucket" "example" {
  bucket = var.bucket_child

  tags = {
    Name        = var.tags["Name"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example.id
  key    = var.filename_child
  source = var.filepath_child
  etag = filemd5(var.filepath_child)

  lifecycle {
    ignore_changes = [content, source, etag]
  }
}