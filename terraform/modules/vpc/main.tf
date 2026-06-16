# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "custom-vpc" }
}

# Fetch available AZs in your current region
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Public Subnet 1 (AZ A)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0] # First AZ (e.g., us-east-1a)
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-1" }
}

# 2. Public Subnet 2 (AZ B)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1] # Second AZ (e.g., us-east-1b)
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-2" }
}

# 3. The Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "main-igw" }
}

# 4. Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-route-table" }
}

# 5. Connect Subnet 1 to the Route Table
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. Connect Subnet 2 to the Route Table
resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}