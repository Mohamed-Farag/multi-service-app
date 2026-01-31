# Multi-Service User Management Application
check direct push to master no#3
## Project Overview
This is a microservices-based application that provides user management and data processing capabilities. The application consists of two independent services that work together to provide a complete user management solution.

### Key Features
- User data management (create, read, updat and delete)
- Intelligent data processing and analysis
- web interface for both services
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
- Docker Desktop (Windows/macOS) or Docker Engine + Docker Compose v2 (Linux)
- Python 3.9 and pip
- Git

### Docker Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd multi-service-app
```

2. Start Docker
- Windows/macOS: start Docker Desktop
- Linux: `sudo systemctl start docker`

3. Build and start the services using Compose (recommended):
```bash
# Use Docker Compose v2 (recommended)
docker compose up --build
# Or detached:
docker compose up --build -d
```

This will:
- Build Docker images for both services using the `build:` contexts
- Create a Docker network for service communication
- Start both services in containers
- Map host ports 3000 -> container 5000 and 3001 -> container 5001 (containers communicate over container ports 5000/5001)

4. To stop the services:
```bash
docker compose down
```

### Verifying the Setup
1. Service A should be accessible at: http://localhost:3000
2. Service B should be accessible at: http://localhost:3001
3. Quick smoke test (from host):
```bash
# create a user in Service A
curl -sSf -X POST -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}' http://localhost:3000/users

# process the user in Service B
curl -sSf -X POST http://localhost:3001/process/user/1
```

Alternatively, use the web UIs:
- Create a user through Service A's interface (http://localhost:3000)
- Process the user through Service B's UI (http://localhost:3001)

## Running Tests

### Unit tests locally
1. Install dependencies and run tests for a service:
```bash
cd service_a
pip install -r requirements.txt
pytest -v
```

Repeat for `service_b`.

### Running tests in Docker
You can run tests inside containers:
```bash
docker compose run --rm service_a python -m pytest test_app.py -v
docker compose run --rm service_b python -m pytest test_app.py -v
```

### Integration smoke test
After `docker compose up --build -d` run:
```bash
# create a user in Service A
curl -sSf -X POST -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}' http://localhost:3000/users

# process it in Service B and validate output
curl -sSf -X POST http://localhost:3001/process/user/1
```

## Troubleshooting

### Docker-specific Issues
1. If containers fail to start:
   - Check Docker Compose logs: `docker compose logs`
   - Verify port availability
   - Check Docker daemon status (`sudo systemctl status docker` on Linux) or Docker Desktop on Windows/macOS

2. If services can't communicate:
   - Verify Docker network: `docker network ls`
   - Check container logs: `docker compose logs service_a service_b`
   - Ensure service URLs are correct in environment variables (use `http://service_a:5000` inside Compose)

## CI notes
- The repository includes a GitHub Actions workflow that builds images, runs unit tests, and runs integration smoke tests using the `docker/compose-action` to build and run services locally. If you change service ports or the Compose file, update `.github/workflows/ci.yml` accordingly.

## Support
For issues and feature requests, please create an issue in the repository.
