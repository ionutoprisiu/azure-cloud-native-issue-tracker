# azure-cloud-native-issue-tracker

Cloud-native issue tracker built on Microsoft Azure using Terraform, Azure Container Apps, Docker and Azure DevOps CI/CD.

The project is focused mainly on DevOps and cloud engineering rather than application complexity. The application consists of a React frontend and a FastAPI backend, both containerized with Docker and deployed to Azure Container Apps.

The infrastructure is provisioned with Terraform and organized into separate platform and workload layers. It includes Azure networking, Azure Container Registry, managed identities, RBAC and remote Terraform state stored in Azure Blob Storage.

Azure DevOps pipelines are used to validate Terraform, generate and approve infrastructure plans, build and test Docker images, push them to Azure Container Registry and deploy new application revisions.

Work in progress. PostgreSQL, private database connectivity, frontend CI/CD and additional infrastructure improvements are planned.