
module "s3_bucket" {
  source = "./modules/s3"
  bucket_child = var.bucket_root
  filepath_child = var.filepath_root
  filename_child = var.filename_root
}


module "my_custom_network" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"
}

# 2. Instantiate the Security Groups Module
module "my_security_groups" {
  source = "./modules/sg"
  
  # Connects the two modules seamlessly:
  vpc_id = module.my_custom_network.vpc_id 
}

# 3. Load Balancing Layer
module "my_alb" {
  source            = "./modules/alb"
  vpc_id            = module.my_custom_network.vpc_id
  public_subnet_ids = module.my_custom_network.public_subnet_ids # Passes both subnets
  alb_sg_id         = module.my_security_groups.alb_sg_id       # Passes the ALB Security Group

  # Replace this string with your real ACM Certificate ARN
  certificate_arn   = "arn:aws:acm:eu-central-1:064318812275:certificate/65f34f82-029a-430a-a147-76393853314c"
}

# 4. Compute Layer (NEW)
module "my_template" {
  source                    = "./modules/template"
  instance_sg_id            = module.my_security_groups.app_sg_id # Pass the instance-level SG
  
  # Swap this out with the actual name of your existing IAM Instance Profile / Role
  iam_instance_profile_name = "ec2-portfoliorole" 
  
  # Optional override if you are not in us-east-1
  # ami_id                  = "ami-xxxxxx" 

  # New interconnected variables:
  public_subnet_ids         = module.my_custom_network.public_subnet_ids # Feeds subnets to ASG
  target_group_arn          = module.my_alb.target_group_arn            # Feeds target group to ASG
}

