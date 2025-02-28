terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create ECR Repositories
resource "aws_ecr_repository" "flask-api-repo" {
  name = "flask-api-repo"
}

resource "aws_ecr_repository" "flask-client-repo" {
  name = "flask-client-repo"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "flask-cluster" {
  name = "flask-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/flask-project"
  retention_in_days = 7  # Optional: Set log retention
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "services" {
  family                   = "flask-project-services"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::730335323304:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "api-service"
      image     = "${aws_ecr_repository.flask-api-repo.repository_url}:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/flask-project"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "client-service"
      image     = "${aws_ecr_repository.flask-client-repo.repository_url}:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/flask-project"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Create Security Group for ECS Service
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = "vpc-0a6b506afbd4c5fd0"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ECS Service
resource "aws_ecs_service" "flask-service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.flask-cluster.id
  task_definition = aws_ecs_task_definition.services.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0f589277124822a92", "subnet-091f161d52ffc95ac"]  # Replace with your subnet IDs
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
