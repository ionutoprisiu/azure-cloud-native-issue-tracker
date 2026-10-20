
# Azure Cloud-Native Issue Tracker

A cloud-native issue tracking application built with **React, FastAPI, PostgreSQL, Docker, Terraform, and Microsoft Azure**.

The project focuses on DevOps and Cloud Engineering practices, including Infrastructure as Code (IaC), cloud networking, containerization, security, and automated deployments using Azure DevOps CI/CD.

## Tech Stack

- **Cloud:** Microsoft Azure
- **Infrastructure as Code:** Terraform
- **CI/CD:** Azure DevOps, YAML Pipelines
- **Containers:** Docker, Azure Container Apps, Azure Container Registry
- **Backend:** Python, FastAPI, PostgreSQL
- **Frontend:** React, Vite, Nginx
- **Scripting:** Bash
- **Networking:** VNets, VNet Peering, NSGs, Private Endpoints, Private DNS

## Architecture

The infrastructure is organized into four Terraform layers:

| Layer | Description |
|-------|-------------|
| Bootstrap | Azure Storage for Terraform remote state |
| Platform | Networking, Container Registry, Key Vault, identities and RBAC |
| Data | PostgreSQL Flexible Server and private connectivity |
| Workload | Azure Container Apps for frontend and backend |

Each layer is managed through separate Terraform configurations and state files.

The application follows a simple three-tier architecture:

```text
React Frontend
      |
      v
FastAPI Backend
      |
      v
PostgreSQL Database
```

## Key Features

- Infrastructure provisioning with Terraform
- Hub-and-spoke Azure network architecture
- Containerized frontend and backend services
- Private PostgreSQL connectivity
- Azure Key Vault and Managed Identity integration
- Role-Based Access Control (RBAC)
- Automated infrastructure and application delivery pipelines
- Docker-based testing and deployment verification

## CI/CD

The project includes five Azure DevOps YAML pipelines:

- `platform-cicd.yaml`
- `data-cicd.yaml`
- `workload-cicd.yaml`
- `backend-cicd.yaml`
- `frontend-cicd.yaml`

Infrastructure pipelines implement Terraform validation, planning, approval and deployment stages.

Application pipelines define Docker image builds, container tests, image publishing to Azure Container Registry and deployment to Azure Container Apps.

## Project Structure

```text
azure-cloud-native-issue-tracker/
├── app/
│   ├── frontend/
│   ├── backend/
│   └── compose.yaml
├── infrastructure/
│   ├── bootstrap/
│   ├── platform/
│   ├── data/
│   └── workload/
├── pipelines/
└── README.md
```

## Local Development

The application can be run locally using Docker Compose.

Create an `app/.env` file with the required PostgreSQL configuration, then run:

```bash
cd app
docker compose up -d --build
```

Available endpoints:

- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- API Documentation: http://localhost:8000/docs

Stop the application:

```bash
docker compose down
```

## Project Status

- Application developed and tested locally using Docker Compose
- Terraform infrastructure implemented and statically validated
- Azure DevOps CI/CD pipelines configured
- Azure networking, identity and secrets management integrated into the infrastructure configuration
- Complete end-to-end Azure deployment pending final verification

## Project Goal

This project demonstrates practical DevOps and cloud engineering skills through infrastructure automation, cloud architecture, security configuration and CI/CD workflows.
