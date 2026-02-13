# ECS Cluster: The logical grouping of our services
resource "aws_ecs_cluster" "main" {
  name = "multi-service-cluster"

  # Enables CloudWatch Container Insights (metrics like CPU/Memory usage)
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Service Discovery Namespace
# Allows services to talk to each other via "service.local" domain
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "service.local"
  description = "Service discovery namespace"
  vpc         = aws_vpc.main.id
}

# ----------------- SERVICE A -----------------

# Task Definition: The "blueprint" for the container
resource "aws_ecs_task_definition" "service_a" {
  family                   = "service-a"
  network_mode             = "awsvpc"                    # Required for Fargate
  requires_compatibilities = ["FARGATE"]                 # "Serverless" compute
  cpu                      = 256                         # 0.25 vCPU
  memory                   = 512                         # 512 MB RAM
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn # Role to pull images
  task_role_arn            = aws_iam_role.ecs_task_role.arn      # Role for the app itself

  container_definitions = jsonencode([
    {
      name      = "service-a"
      image     = "mohamedfarag96/service_a:latest"   # Docker image to run
      essential = true
      portMappings = [
        {
          containerPort = 5000                        # Container listens on port 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}
# Service Discovery Record for Service A
# Registers "service-a.service.local" -> IP of the container
resource "aws_service_discovery_service" "service_a" {
  name = "service-a"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ECS Service: The "Runner" that keeps the task alive
resource "aws_ecs_service" "service_a" {
  name            = "service-a"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_a.arn
  desired_count   = 1           # Run 1 copy of the container
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id] # Only allow ALB traffic
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    assign_public_ip = true     # Needed to pull images from Docker Hub
  }

  # Connects the service to the Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.service_a.arn
    container_name   = "service-a"
    container_port   = 5000
  }

  # Registers the service with Service Discovery
  service_registries {
    registry_arn = aws_service_discovery_service.service_a.arn
  }
}

# ----------------- SERVICE B -----------------

resource "aws_ecs_task_definition" "service_b" {
  family                   = "service-b"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "service-b"
      image     = "mohamedfarag96/service_b:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
        }
      ]
      # Tell Service B where to find Service A
      environment = [
        {
          name  = "SERVICE_A_URL"
          value = "http://service-a.service.local:5000" # <--- Internal DNS Name!
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service_b" {
  name            = "service-b"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_b.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_b.arn
    container_name   = "service-b"
    container_port   = 5001
  }
}
