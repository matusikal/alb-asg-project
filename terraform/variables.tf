variable "bucket_root" {
  description = "The name of the root S3 bucket (must be globally unique)"
  type        = string
}
variable "filepath_root" {
  description = "The local path to the file to be uploaded to S3"
  type        = string
  default     = "../index.php"
}
variable "filename_root" {
  description = "The name of the file in the S3 bucket"
  type        = string
  default     = "index.php"
}

