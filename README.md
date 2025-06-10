# Multi-Service User Management Application

## Project Overview
This is a microservices-based application that provides user management and data processing capabilities. The application consists of two independent services that work together to provide a complete user management solution.

### Key Features
- User data management (create, read, update, delete)
- Intelligent data processing and analysis
- Modern web interface for both services
- RESTful API endpoints
- Real-time data processing
- Docker containerization support

## Architecture Diagram
```
┌─────────────────┐     HTTP     ┌─────────────────┐
│                 │   Request    │                 │
│  Service A      │────────────▶ │  Service B      │
│  (Port 5000)    │◀─────────────│  (Port 5001)    │
│                 │   Response   │                 │
└─────────────────┘              └─────────────────┘
        │                                 │
        │                                 │
        ▼                                 ▼
┌─────────────────┐              ┌─────────────────┐
│  User Data      │              │  Data           │
│  Storage        │              │  Processing     │
│  (In-Memory)    │              │  Engine         │
└─────────────────┘              └─────────────────┘

Service A (User Management):
├── Web Interface
├── REST API
└── In-Memory Storage

Service B (Data Processing):
├── Web Interface
├── Name Analysis
└── Email Analysis
```

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- Git

### Docker Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd multi-service-app
```

2. Build and start the services using Docker Compose:
```bash
docker-compose up --build
```

This will:
- Build Docker images for both services
- Create a Docker network for service communication
- Start both services in containers
- Map the required ports (5000 and 5001)

3. To run in detached mode:
```bash
docker-compose up -d
```

4. To stop the services:
```bash
docker-compose down
```

### Verifying the Setup
1. Service A should be accessible at: http://localhost:5000
2. Service B should be accessible at: http://localhost:5001
3. Test the services by:
   - Creating a user through Service A's interface
   - Processing the user data through Service B's interface

## Deployment Process

### Docker Deployment

1. Build the Docker images:
```bash
docker-compose build
```

2. Deploy using Docker Compose:
```bash
docker-compose up -d
```

3. Verify deployment:
```bash
docker-compose ps
```

### Production Deployment Considerations
- Use Docker Swarm or Kubernetes for orchestration
- Set up proper logging with Docker logging drivers
- Configure environment variables for production
- Implement proper security measures
- Set up monitoring and alerting
- Use Docker secrets for sensitive data

### Health Checks
- Service A: http://localhost:5000/users
- Service B: http://localhost:5001/process/user/1

## API Documentation

### Service A Endpoints
- `GET /users` - List all users
- `GET /users/<user_id>` - Get specific user
- `POST /users` - Create new user
- `PUT /users/<user_id>` - Update user
- `DELETE /users/<user_id>` - Delete user

### Service B Endpoints
- `POST /process/user/<user_id>` - Process user data

## Troubleshooting

### Docker-specific Issues
1. If containers fail to start:
   - Check Docker logs: `docker-compose logs`
   - Verify port availability
   - Check Docker daemon status

2. If services can't communicate:
   - Verify Docker network: `docker network ls`
   - Check container logs: `docker-compose logs service_a service_b`
   - Ensure service URLs are correct in environment variables

### General Issues
1. If services fail to start:
   - Check if ports 5000 and 5001 are available
   - Verify all dependencies are installed
   - Check Python version compatibility

2. If services can't communicate:
   - Verify both services are running
   - Check network connectivity
   - Verify service URLs are correct

## Support
For issues and feature requests, please create an issue in the repository.