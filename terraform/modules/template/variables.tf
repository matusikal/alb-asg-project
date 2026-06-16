variable "instance_sg_id" {
  type        = string
  description = "The security group ID for the EC2 instances (app-sg)"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "The name of your pre-existing IAM Instance Profile"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the instances"
  default     = "ami-09f224bab7225d943"
}

variable "instance_type" {
  type        = string
  description = "The size of the instance"
  default     = "t3.nano"
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the ASG will launch instances"
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the ALB target group for instance registration"
}