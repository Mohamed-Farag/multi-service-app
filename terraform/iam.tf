# Execution Role:
# This gives the ECS "Agent" permission to do things ON BEHALF of your container (before it starts)
# e.g., Pulling the image from Docker Hub, Sending logs to CloudWatch
resource "aws_iam_role" "ecs_execution_role" {
  name = "multi-service-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the standard Amazon-managed policy for ECS execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role:
# This gives the RUNNING CONTAINER permission to call other AWS services
# e.g., if your Python code used boto3 to write to S3, you would attach policies here.
resource "aws_iam_role" "ecs_task_role" {
  name = "multi-service-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
