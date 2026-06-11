variable "bucket_child" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

variable filepath_child {
  type = string
  default = "../index.php"
}

variable "filename_child" {
  type = string
  default = "index.php"
}