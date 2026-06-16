output "launch_template_id" {
  value       = aws_launch_template.app_lt.id
  description = "The ID of the Launch Template"
}