variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "alb_sg_id" {
  type        = string
  description = "The Security Group ID assigned to the ALB"
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the custom SSL/TLS certificate from AWS Certificate Manager (ACM)"
}