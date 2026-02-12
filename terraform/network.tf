resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # The IP range for the entire network (65,536 IPs)
  enable_dns_hostnames = true          # Allows resources to have DNS names (e.g., ec2-....amazonaws.com)
  enable_dns_support   = true          # Enables the Amazon-provided DNS server

  tags = {
    Name = "multi-service-vpc"
  }
}

# The gateway to the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Attaches the gateway to our VPC

  tags = {
    Name = "multi-service-igw"
  }
}

# Get list of available Availability Zones in the region (e.g., eu-central-1a, 1b...)
data "aws_availability_zones" "available" {
  state = "available"
}

# Create 2 Public Subnets
resource "aws_subnet" "public" {
  count             = 2                                                           # Create 2 subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"                                  # 10.0.0.0/24 and 10.0.1.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]    # Distribute across AZs

  map_public_ip_on_launch = true # Instances launched here get a public IP automatically

  tags = {
    Name = "multi-service-public-${count.index + 1}"
  }
}

# Routing rules for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route 0.0.0.0/0 (all traffic) to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "multi-service-public-rt"
  }
}

# Associate the Route Table with the Subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for the Load Balancer (The "Front Door")
resource "aws_security_group" "alb" {
  name        = "multi-service-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (Port 8080) from anywhere
  ingress {
    description = "HTTP 8080 from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "multi-service-alb-sg"
  }
}

# Security Group for ECS Tasks (The Containers)
resource "aws_security_group" "ecs_tasks" {
  name        = "multi-service-ecs-tasks-sg"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.main.id

  # Only allow traffic from the Load Balancer
  ingress {
    description     = "HTTP from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id] # <--- Reference to ALB SG ID
  }

  # Allow internal communication between services (Service A <-> Service B)
  ingress {
    description = "Internal communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true # Allow traffic from other resources with THIS same security group
  }

  # Allow containers to talk to the internet (e.g. download Docker images)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "multi-service-ecs-tasks-sg"
  }
}
