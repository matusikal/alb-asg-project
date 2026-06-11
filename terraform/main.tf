module "s3_demo_bucket" {
  source = "./modules/s3"

  # Map the root variables into the child module inputs
  bucket_name = var.root_bucket_name
  environment = var.root_environment
}

# Example of how you would use the S3 output later in your IAM Role:
resource "aws_iam_policy" "s3_access" {
  name        = "EC2-S3-Access-Policy"
  description = "Allows EC2 to read from our demo bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          module.s3_demo_bucket.bucket_arn,
          "${module.s3_demo_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
}