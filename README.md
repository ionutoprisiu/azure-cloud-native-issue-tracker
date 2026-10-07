# azure-cloud-native-issue-tracker

Cloud-native issue tracker built on Microsoft Azure using Terraform, Azure Container Apps, Docker and Azure DevOps CI/CD.

The project focuses primarily on DevOps and cloud engineering rather than application complexity. The application consists of a React frontend and a FastAPI backend, both containerized with Docker.

Infrastructure is provisioned with Terraform and separated into four layers:

- **bootstrap** – Azure Storage backend for Terraform remote state
- **platform** – hub-and-spoke networking, routing, Azure Container Registry, Key Vault, managed identities and RBAC
- **data** – Azure Database for PostgreSQL Flexible Server, Private Endpoint and Private DNS
- **workload** – Azure Container Apps environments and application workloads

The backend Container App is configured to consume the PostgreSQL private FQDN and database name from the data layer through Terraform remote state.

Azure DevOps pipelines validate and plan Terraform changes, use manual approval gates before infrastructure apply, and build, test and deploy the backend container image.

## Application

- React + Vite frontend
- FastAPI backend
- PostgreSQL persistence
- Docker containers

## Current status

Infrastructure code for the PostgreSQL data layer and private connectivity is implemented.

The next steps are to complete the frontend integration and CI/CD, connect the FastAPI application to PostgreSQL, and replace the temporary frontend image in the workload configuration with the actual React application image.