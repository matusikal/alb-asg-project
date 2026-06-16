resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.instance_sg_id]
  }

  user_data = filebase64("${path.module}/ec2config.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "app-asg-"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest" 
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "asg-app-server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "cpu-tracking"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}