# Azure Cloud-Native Issue Tracker

Cloud-native issue tracker built with Microsoft Azure, Terraform, Docker, PostgreSQL and Azure DevOps CI/CD.

The project focuses mainly on DevOps and cloud engineering rather than application complexity. Its purpose is to demonstrate Infrastructure as Code, cloud networking, containerization, secrets management and automated application delivery.

The application consists of:

- React + Vite frontend
- FastAPI backend
- PostgreSQL database
- Dockerized application components

## Architecture

The Azure infrastructure is provisioned with Terraform and separated into four layers:

- **bootstrap** – Azure Blob Storage used for Terraform remote state
- **platform** – virtual networks, routing, Azure Container Registry, Key Vault, managed identities, NSGs and RBAC
- **data** – Azure Database for PostgreSQL Flexible Server, Private Endpoint and Private DNS
- **workload** – Azure Container Apps environments and frontend/backend workloads

Each infrastructure layer uses its own Terraform state file.

```text
Azure Blob Storage
│
├── platform.tfstate
├── data.tfstate
└── workload.tfstate
```

The dependency flow between the main infrastructure layers is:

```text
Platform
   ↓
Data
   ↓
Workload
```

## Azure Infrastructure

The platform uses separate VNets for the main application layers:

```text
Hub       10.0.0.0/24
Frontend  10.0.1.0/24
Backend   10.0.2.0/24
Data      10.0.3.0/24
```

Networking components include:

- VNet peering
- Network Security Groups
- User Defined Routes
- Linux Network Virtual Appliance
- Private Endpoint
- Private DNS

Azure Container Registry stores the frontend and backend Docker images.

The frontend and backend are deployed as Azure Container Apps using User Assigned Managed Identities for access to Azure resources.

## PostgreSQL

The data layer provisions:

- Azure Database for PostgreSQL Flexible Server
- `issue_tracker` database
- Private Endpoint
- Private DNS Zone
- Key Vault secret for the PostgreSQL password

Public network access to PostgreSQL is disabled.

The backend receives database configuration through environment variables:

```text
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_SSLMODE
```

The PostgreSQL password is stored in Azure Key Vault and referenced by the backend Container App using managed identity and Azure RBAC.

```text
Backend Container App
        ↓
Managed Identity
        ↓
Azure Key Vault
        ↓
PostgreSQL password
```

## Application

### Frontend

The frontend is built with:

- React
- Vite
- Nginx
- Docker

The backend API URL is injected during the frontend Docker build using:

```text
VITE_API_URL
```

For Azure deployments, the frontend pipeline retrieves the backend Container App FQDN and uses it when building the React application.

### Backend

The backend is built with:

- FastAPI
- SQLAlchemy
- Psycopg
- PostgreSQL
- Docker

The API provides basic issue management operations:

```text
GET     /issues
GET     /issues/{id}
POST    /issues
PATCH   /issues/{id}/status
DELETE  /issues/{id}
```

A health endpoint is also available:

```text
GET /health
```

SQLAlchemy is used for database access and creates the required application tables when the backend starts.

## Local Development

The complete application can be run locally with Docker Compose.

```text
React Frontend
      ↓
FastAPI Backend
      ↓
PostgreSQL
```

Create an `app/.env` file:

```env
POSTGRES_DB=issue_tracker
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
```

Start the stack:

```bash
cd app
docker compose up -d --build
```

Check the running services:

```bash
docker compose ps
```

Local endpoints:

```text
Frontend:
http://localhost:5173

Backend:
http://localhost:8000

FastAPI documentation:
http://localhost:8000/docs

Health endpoint:
http://localhost:8000/health
```

PostgreSQL data is persisted using a Docker volume.

Stop the stack with:

```bash
docker compose down
```

To also delete the database volume:

```bash
docker compose down -v
```

## CI/CD

Azure DevOps pipelines are used for both infrastructure provisioning and application delivery.

The repository contains:

```text
platform-cicd.yaml
data-cicd.yaml
workload-cicd.yaml
backend-cicd.yaml
frontend-cicd.yaml
```

### Infrastructure Pipelines

The main infrastructure pipeline flow is:

```text
platform-cicd
      ↓
data-cicd
      ↓
workload-cicd
```

Terraform pipelines include:

```text
Validate
   ↓
Plan
   ↓
Manual Approval
   ↓
Apply
```

The PostgreSQL administrator password is stored as an Azure DevOps secret variable and injected into Terraform through:

```text
TF_VAR_postgresql_admin_password
```

The password is not stored in the repository.

### Backend Pipeline

The backend pipeline performs:

```text
Build Docker image
        ↓
Start PostgreSQL test container
        ↓
Start backend test container
        ↓
Health check
        ↓
Push image to ACR
        ↓
Update backend Container App
        ↓
Verify deployed health endpoint
```

This allows the backend to be tested against PostgreSQL before deployment.

### Frontend Pipeline

The frontend pipeline performs:

```text
Read backend Container App FQDN
        ↓
Build frontend Docker image
        ↓
Inject VITE_API_URL
        ↓
Test Nginx container
        ↓
Push image to ACR
        ↓
Update frontend Container App
        ↓
Verify deployed frontend
```

## Security

The project includes several Azure security patterns:

- Azure Container Registry admin access disabled
- User Assigned Managed Identities
- Azure RBAC
- Azure Key Vault for database credentials
- PostgreSQL public network access disabled
- Private Endpoint connectivity
- Private DNS
- Network Security Groups
- Separate VNets for application layers
- Terraform remote state stored in Azure Blob Storage
- CI/CD secrets kept outside the repository

## Repository Structure

```text
azure-cloud-native-issue-tracker/
│
├── app/
│   ├── backend/
│   │   ├── database.py
│   │   ├── main.py
│   │   ├── models.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── frontend/
│   │   ├── src/
│   │   └── Dockerfile
│   │
│   └── compose.yaml
│
├── infrastructure/
│   ├── bootstrap/
│   ├── platform/
│   ├── data/
│   └── workload/
│
├── pipelines/
│   ├── platform-cicd.yaml
│   ├── data-cicd.yaml
│   ├── workload-cicd.yaml
│   ├── backend-cicd.yaml
│   └── frontend-cicd.yaml
│
└── README.md
```

## Technologies

### Cloud

- Microsoft Azure
- Azure Container Apps
- Azure Container Registry
- Azure Database for PostgreSQL Flexible Server
- Azure Key Vault
- Azure Virtual Network
- Azure Private Endpoint
- Azure Private DNS
- Azure Blob Storage
- Azure Managed Identity
- Azure RBAC

### DevOps

- Terraform
- Azure DevOps
- YAML pipelines
- Docker
- Docker Compose
- Bash
- Git

### Application

- Python
- FastAPI
- SQLAlchemy
- Psycopg
- PostgreSQL
- React
- Vite
- Nginx

## Current Status

The application is fully functional locally using Docker Compose with persistent PostgreSQL storage.

The Terraform configuration for the platform, data and workload layers has been implemented and validated.

CI/CD definitions are implemented for:

- platform infrastructure
- PostgreSQL infrastructure
- Container Apps workloads
- backend delivery
- frontend delivery

The backend is configured to use private PostgreSQL connectivity and retrieve its database password from Azure Key Vault using managed identity.

The latest Azure infrastructure and CI/CD additions are implemented and statically validated. A final live deployment of the complete configuration requires an active Azure subscription.

## Project Goal

The goal of this project is to demonstrate practical DevOps and cloud engineering skills through a complete cloud application delivery workflow:

```text
Infrastructure as Code
        +
Cloud Networking
        +
Containerization
        +
Secrets Management
        +
CI/CD
        +
Application Delivery
```

The project intentionally prioritizes infrastructure, automation and cloud architecture over application complexity.