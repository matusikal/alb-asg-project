resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Attach your pre-existing IAM Role via its Instance Profile
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Network configuration (Attaches the app/instance security group)
  network_interfaces {
    associate_public_ip_address = true # Keep instances private if desired, or true if needed
    security_groups             = [var.instance_sg_id]
  }

  # Optional: Adds a basic user data script to test web traffic
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

# Existing aws_launch_template.app_lt stays above...

# NEW: Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "app-asg-"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids # Spreads instances across both subnets

  # Link to your Launch Template
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest" # Automatically uses the newest version of the template
  }

  # Link to your ALB Target Group
  target_group_arns = [var.target_group_arn]

  # Use ALB health checks instead of basic EC2 instance status checks
  health_check_type         = "ELB"
  health_check_grace_period = 300 # Gives instances 5 minutes to run userdata.sh before checking health

  # Enforce instances to replace cleanly when the launch template updates
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
    propagate_at_launch = true # This makes sure instances get tagged
  }
}