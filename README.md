# DevSecOps CI/CD Pipeline

![Docker](https://img.shields.io/badge/Docker-Container-blue?logo=docker&style=flat-square)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red?logo=jenkins&style=flat-square)
![SonarQube](https://img.shields.io/badge/SonarQube-Code_Quality-teal?logo=sonarqube&style=flat-square)
![Trivy](https://img.shields.io/badge/Trivy-Security-purple?logo=github&style=flat-square)
![Gitleaks](https://img.shields.io/badge/Gitleaks-SAST-orange?logo=github&style=flat-square)
![Maven](https://img.shields.io/badge/Maven-Build%20Tool-009999?style=flat-square&logo=apachemaven&logoColor=white)

## Overview
This repository contains a Java-based application integrated with a complete production-grade DevSecOps CI/CD pipeline using Jenkins.

The pipeline automatically builds, scans, and publishes the application using modern DevSecOps tools. It is designed to be beginner-friendly and runs entirely on a local setup using Jenkins, Docker, SonarQube, Trivy, and Pre-Commit.

This project demonstrates how to combine:
- CI/CD automation
- Code quality scanning
- Apache Maven for Java build automation
- Secret detection
- Container security scanning
- Docker image publishing

## Features
- ✅ Automatic GitHub code checkout
- 🔐 Secret scanning using pre-commit + Gitleaks
- 📦 Maven build (mvn clean package)
- 🧪 Test execution
- 📊 SonarQube static code analysis
- 🚦 SonarQube Quality Gate enforcement
- 🐳 Docker image build using project Dockerfile
- 🛡 Docker image vulnerability scan using Trivy
- 📤 Automatic DockerHub image push

## Jenkins CI/CD Pipeline Architecture
![CI/CD Pipeline](/home/dhaninfo/TheRecker/Projcets/Client-Browser-Information/images/Client-Info.png)

## Prerequisites
Install the following tools on your local system:

- Jenkins
- Docker
- Java (JDK 21)
- Apache Maven
- SonarQube Server
- Trivy
- Python + pre-commit
- Git

## Jenkins Server Configuration
### 1. Install Required Jenkins Plugins
Go to: Manage Jenkins → Plugins

Install:

- NodeJS Plugin
- SonarQube Scanner Plugin
- SonarQube Quality Gates Plugin
- Credentials Binding Plugin
- Docker Pipeline Plugin
- Restart Jenkins after installation.  

---

### 2. Configure Java & Maven in Jenkins
This is required or npm commands will fail.  
Manage Jenkins → Global Tool Configuration → Maven & Java

#### Add:

| Field | Value |
|--------|---------|
| Name | `jdk-21` & `maven-3.9.6` |
| Install automatically | Enabled |

Must match Jenkinsfile:
```
tools {
    maven "maven-3.9.6"
    jdk "jdk-21"
}
```
---

### 3. Configure SonarQube Server in Jenkins

#### Step 1 — Create Token in SonarQube

1. Open **SonarQube**
2. Go to:
   **My Account → Security → Generate Token**
3. Click **Generate Token**
4. Copy the generated token (you will use it in Jenkins credentials)

#### Step 2 — Add SonarQube Server in Jenkins

1. Open **Jenkins**
2. Navigate to:
   **Manage Jenkins → Configure System**
3. Scroll to **SonarQube Servers**
4. Click **Add SonarQube**

#### Enter the following details:

| Field | Value |
|--------|---------|
| Name | `sonar-local` |
| Server URL | `http://localhost:9000` |
| Credentials | **Secret Text** → paste SonarQube token |

#### Step 3 — Configure Sonar Scanner Tool

1. Go to:
   **Manage Jenkins → Global Tool Configuration**
2. Scroll to **SonarQube Scanner**
3. Click **Add SonarQube Scanner**

#### Configure:

| Field | Value |
|--------|---------|
| Name | `sonar-scanner` |
| Install Automatically | Enabled |

### Important Note
Your scanner name **must match** what you use in your Jenkinsfile:
```groovy
tool 'sonar-scanner'
```
---

## SonarQube Webhook Configuration  

Without this step, the pipeline will hang at Quality Gate stage.

Open SonarQube:

1. Goto : **Administration → Configuration → Webhooks → Create**

#### Add:

| Field | Value |
|--------|---------|
| Name | `jenkins` |
| URL | http://<'IP address of Jenkins Server'>:8080/sonarqube-webhook/ |

---

## Docker Setup for Jenkins

Allow Jenkins to run Docker:
```
sudo usermod -aG docker jenkins

sudo systemctl restart jenkins
```

Test:
```
sudo su - jenkins docker ps -a
```

---

## Add DockerHub Credentials in Jenkins

Goto: **Manage Jenkins → Credentials → Add**

Add:
| Field | Value |
|--------|---------|
| Kind | Username/Password |
| ID | dockerhub-creds |
 
---

## Pre-Commit & Gitleaks Setup

Install:
```
pip install pre-commit

nano .pre-commit-config.yaml
```
Add below :
```
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.2
    hooks:
      - id: gitleaks
      
```


Pipeline runs:
```
pre-commit run --all-files
```

This checks for:  
- API keys  
- passwords  
- secrets in code

---


## Trivy Setup
Install Trivy:
```
trivy --version
```
Pipeline scan command:
```
trivy image IMAGE:TAG
```
Scans Docker image for vulnerabilities.

---
