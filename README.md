# AWS Node.js Deployment with EC2, Docker, and Jenkins

This project demonstrates how to deploy a Node.js application on an AWS EC2 instance using Docker and Jenkins CI/CD. The setup ensures automatic versioning, container deployment, and secure access from the browser, following best practices for infrastructure-as-code and automation.

---

## Project Structure

The application is dockerized and deployed using the following components:

* **EC2 instance** in a custom **VPC**
* **Docker & Docker Compose** for containerization and deployment
* **Jenkins multibranch pipeline** for automated CI/CD
* **IAM setup and AWS CLI** for scripting infrastructure
* **Security Group rules** to expose the app over the internet

---

### AWS Infrastructure Setup

Step-by-step CLI instructions to:

* Create IAM user and configure AWS CLI
* Set up a custom VPC and subnet
* Define security groups with SSH (port 22) and HTTP (port 3000) access
* Launch an EC2 instance

**See: [`aws-hands-on.md`](./aws-hands-on.md)** for the full CLI setup instructions.

---

### Add Docker Compose

The `docker-compose.yaml` file simplifies deployment and allows service expansion (e.g., adding a database).  
It uses an environment variable `IMAGE` for flexibility:

**Why `IMAGE`?**  
The image name is dynamically generated during the CI pipeline (based on `npm version` + build number) and passed to `docker-compose` during deployment.

---

### Jenkins CI/CD Pipeline

The `Jenkinsfile` automates the following:

* Runs tests on all branches
* Only on `main`:

  * Increments app version in `package.json`
  * Builds and pushes Docker image to Docker Hub
  * SSH into EC2 and deploys the latest image with `docker-compose`
  * Commits updated version back to GitHub

### Deployment Script (`shell-cmds.sh`)
Used on the EC2 server to run the correct dockerized version of the app. It:

1. Exports the Docker image name passed from Jenkins  
2. Sources Docker credentials from a secure `.env` file  
3. Executes `docker-compose` to launch the app container

`shell-cmds.sh` is securely copied to the EC2 instance by Jenkins and then executed on the server via SSH, using Jenkins' SSH agent and credentials.

### Docker Compose Installation & Credential Setup

To enable Docker-based deployment on the EC2 instance, we:

1. **Installed Docker Compose manually**
   EC2 AMI (Amazon Linux) doesn't come with Docker Compose preinstalled, so we use the following command to install the latest version:

   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   docker-compose version
   ```

2. **Configured secure Docker Hub credentials**
   We create a file named `.docker-creds.env` on the EC2 server to store Docker Hub credentials (e.g., `DOCKER_USERNAME`, `DOCKER_PASSWORD`). This file is:

   * **Restricted with `chmod 600`** to prevent unauthorized access
   * **Sourced** before running `docker login` or `docker-compose` to ensure private image access during deployment

   ```bash
   /home/ec2-user/.docker-creds.env  # contains export DOCKER_USERNAME=... and DOCKER_PASSWORD=...
   chmod 600 ~/.docker-creds.env
   source ~/.docker-creds.env
   ```

   This keeps secrets out of code and ensures smooth authentication when pulling images from Docker Hub.

---

📁 **Referenced Files** (already included in this repo):

* `Jenkinsfile`
* `Dockerfile` (multi-stage for build + runtime)
* `docker-compose.yaml`
* `.dockerignore`
* `shell-cmds.sh`

---

### Automate Pipeline Triggers

* Configured **Jenkins multibranch pipeline** logic:

  * Only deploys for `main` branch
  * Runs tests for other branches
* Added **webhook** to auto-trigger pipeline from GitHub on code pushes

---

## Result

After pushing to `main`:

* CI builds and tags a new Docker image
* Jenkins deploys the image to EC2 with `docker-compose`
* App is live and accessible via browser on port **3000**

---

## Best Practices Followed

- **Infrastructure as Code** using AWS CLI, Docker, and Jenkinsfile  
- **CI/CD Automation** via Jenkins multibranch pipeline and GitHub webhooks  
- **Containerization** with Docker & multi-stage builds for efficient deployment  
- **Environment Agnostic Deployments** using `docker-compose` and dynamic `IMAGE` naming  
- **Minimal Manual Intervention** – single push to `main` handles build, versioning, and deploy  
- **Security-Aware** – EC2 exposed only on required ports with `.env` secrets management  

---

## Summary

* Automated and production-ready workflow  
* CI/CD best practices (versioning, testing, branching)  
* Infrastructure scripting with AWS CLI  
* Docker-based deployment for simplicity and scalability  

