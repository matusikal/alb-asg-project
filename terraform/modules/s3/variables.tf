variable "bucket_name" {
  description = "The name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}