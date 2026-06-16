output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the ALB security group"
}

output "app_sg_id" {
  value       = aws_security_group.app.id
  description = "The ID of the app server security group"
}