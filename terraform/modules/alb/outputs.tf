output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The public URL/DNS of your Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app_tg.arn
  description = "The ARN of the target group to attach EC2 instances to"
}