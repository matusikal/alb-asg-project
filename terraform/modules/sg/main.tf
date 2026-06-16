# 1. ALB Security Group (Public Facing)
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Allow HTTP and HTTPS traffic from anywhere"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule: Allow all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

# 2. App Server Security Group (Internal Facing)
resource "aws_security_group" "app" {
  name        = "app-security-group"
  description = "Allow HTTP traffic exclusively from the ALB"
  vpc_id      = var.vpc_id

  # Restrict ingress only to the ALB's Security Group ID
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # This is the magic link!
  }

  # Outbound rule: Allow all traffic out (e.g., for updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg" }
}