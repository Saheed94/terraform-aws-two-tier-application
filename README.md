# Terraform AWS Two-Tier Application

A production-inspired two-tier web application infrastructure deployed on **Amazon Web Services (AWS)** using **Terraform**.

This project demonstrates how to design, provision, secure, and manage a two-tier application architecture consisting of a public web/application tier and a private database tier.

The infrastructure is built using reusable Terraform modules, remote Terraform state stored in Amazon S3, automated Ubuntu AMI discovery, AWS networking components, security groups, Amazon EC2, Nginx, and Amazon RDS MySQL.

---

## Project Overview

The objective of this project is to build a secure two-tier application environment on AWS where:

* The web server is deployed in a public subnet.
* Nginx serves a simple HTML application.
* The database is deployed in private subnets.
* The database is not publicly accessible.
* SSH access to the web server is restricted to the administrator's public IP.
* HTTP traffic is publicly accessible.
* Database traffic is only permitted from the EC2 security group.
* Terraform state is stored remotely in Amazon S3.
* Infrastructure is organized into reusable Terraform modules.

### Architecture

```text
                         INTERNET
                            │
                            │ HTTP :80
                            ▼
                  ┌─────────────────────┐
                  │   Internet Gateway  │
                  └──────────┬──────────┘
                             │
                  ┌──────────▼──────────┐
                  │       VPC           │
                  │    10.0.0.0/16      │
                  │                     │
                  │  ┌───────────────┐  │
                  │  │ Public Subnet │  │
                  │  │ 10.0.1.0/24   │  │
                  │  │               │  │
                  │  │ EC2 + Nginx   │  │
                  │  └───────┬───────┘  │
                  │          │           │
                  │          │ TCP 3306  │
                  │          ▼           │
                  │  ┌───────────────┐  │
                  │  │ Private       │  │
                  │  │ Subnet A      │  │
                  │  │ 10.0.2.0/24   │  │
                  │  └───────────────┘  │
                  │          │           │
                  │          │           │
                  │  ┌───────────────┐  │
                  │  │ Private       │  │
                  │  │ Subnet B      │  │
                  │  │ 10.0.3.0/24   │  │
                  │  └───────┬───────┘  │
                  │          │           │
                  │          ▼           │
                  │       RDS MySQL      │
                  │                     │
                  └─────────────────────┘
```

---

# Project Goals

The main goals of this project are to demonstrate practical knowledge of:

* AWS VPC networking
* Public and private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Security groups
* EC2
* Nginx
* Amazon RDS
* Terraform modules
* Terraform variables and outputs
* Terraform data sources
* Remote Terraform state
* Infrastructure security
* Infrastructure verification
* Infrastructure as Code best practices

---

# AWS Services Used

| Service          | Purpose                                                       |
| ---------------- | ------------------------------------------------------------- |
| Amazon VPC       | Provides the isolated network                                 |
| Amazon EC2       | Hosts the web server                                          |
| Amazon RDS       | Hosts the MySQL database                                      |
| Internet Gateway | Provides internet connectivity to the public subnet           |
| NAT Gateway      | Provides outbound internet connectivity for private resources |
| Elastic IP       | Provides a static public IP for the NAT Gateway               |
| Security Groups  | Controls network access                                       |
| Amazon S3        | Stores Terraform remote state                                 |
| IAM              | Provides AWS identity and access management                   |
| Nginx            | Web server running on EC2                                     |

---

# Architecture Design

## 1. VPC

The project creates one VPC:

```text
CIDR: 10.0.0.0/16
```

The VPC provides the network boundary for all project resources.

DNS support and DNS hostnames are enabled so that resources inside the VPC can properly resolve AWS-provided DNS names.

---

# 2. Public Subnet

The public subnet uses:

```text
10.0.1.0/24
```

The subnet is associated with the public route table.

The public route table contains:

```text
0.0.0.0/0 → Internet Gateway
```

The EC2 web server is deployed here.

Because the subnet is public and the EC2 instance receives a public IP, users can access the Nginx web server through HTTP.

---

# 3. Private Subnets

Two private subnets are created:

```text
Private Subnet A
10.0.2.0/24
eu-west-2a

Private Subnet B
10.0.3.0/24
eu-west-2b
```

The use of two Availability Zones allows the RDS DB subnet group to span multiple Availability Zones.

The database itself remains private and does not receive a public IP address.

---

# 4. Internet Gateway

The Internet Gateway provides internet connectivity to the public subnet.

Traffic flow:

```text
EC2
 │
 ▼
Public Route Table
 │
 ▼
Internet Gateway
 │
 ▼
Internet
```

The public route table contains:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

---

# 5. NAT Gateway

The NAT Gateway is deployed in the public subnet.

Its purpose is to allow resources in private subnets to initiate outbound internet connections without becoming directly reachable from the internet.

Traffic flow:

```text
Private Resource
      │
      ▼
Private Route Table
      │
      ▼
NAT Gateway
      │
      ▼
Internet Gateway
      │
      ▼
Internet
```

The NAT Gateway uses an Elastic IP address.

---

# 6. EC2 Web Server

The application/web tier is hosted on an Amazon EC2 instance.

The EC2 instance:

* Runs Ubuntu
* Uses an automatically discovered Ubuntu AMI
* Runs Nginx
* Is deployed into the public subnet
* Receives a public IP
* Allows HTTP traffic
* Restricts SSH access
* Uses a startup script to install and configure Nginx

The EC2 instance type is configurable through Terraform variables.

Default:

```text
t3.micro
```

---

# 7. Automatic Ubuntu AMI Discovery

Instead of hardcoding an AMI ID, Terraform uses the AWS `aws_ami` data source.

Example:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

The EC2 instance then uses:

```hcl
ami = data.aws_ami.ubuntu.id
```

This prevents the project from depending on a hardcoded AMI ID.

The AMI ID is region-specific, so Terraform automatically searches for the image in the configured AWS region.

---

# 8. Nginx Configuration

The EC2 instance uses Terraform `user_data` to automatically configure the server.

The startup process:

```text
EC2 starts
   │
   ▼
User Data executes
   │
   ▼
apt-get update
   │
   ▼
Install Nginx
   │
   ▼
Enable Nginx
   │
   ▼
Start Nginx
   │
   ▼
Create HTML page
```

The web page displays:

```text
Two-Tier Application

Deployed with Terraform on AWS.

EC2 + Nginx is running successfully.
```

---

# 9. Amazon RDS MySQL

The database tier uses Amazon RDS for MySQL.

The database is configured with:

* MySQL engine
* Private subnet placement
* Private DB subnet group
* No public accessibility
* Encryption at rest
* Automated backups
* Configurable storage
* Configurable instance class
* Security group-based access control

Example configuration:

```hcl
engine = "mysql"

instance_class = var.db_instance_class

allocated_storage = var.allocated_storage

publicly_accessible = false

storage_encrypted = true
```

---

# 10. RDS DB Subnet Group

The database subnet group contains both private subnets:

```text
eu-west-2a
10.0.2.0/24

eu-west-2b
10.0.3.0/24
```

This allows RDS to use subnets across multiple Availability Zones.

Terraform configuration:

```hcl
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}
```

---

# Security Architecture

Security is implemented using separate security groups for the web server and database.

## EC2 Security Group

### Inbound

| Port | Protocol | Source                 | Purpose            |
| ---- | -------- | ---------------------- | ------------------ |
| 80   | TCP      | `0.0.0.0/0`            | Public HTTP access |
| 22   | TCP      | Administrator IP `/32` | SSH administration |

### Outbound

The EC2 instance is allowed outbound traffic.

---

## RDS Security Group

### Inbound

| Port | Protocol | Source             | Purpose      |
| ---- | -------- | ------------------ | ------------ |
| 3306 | TCP      | EC2 Security Group | MySQL access |

There is intentionally no rule such as:

```text
3306 → 0.0.0.0/0
```

This means the database cannot be directly accessed from the internet.

The architecture follows:

```text
Internet
   │
   │ HTTP :80
   ▼
 EC2
   │
   │ MySQL :3306
   ▼
 RDS
```

The database only trusts the EC2 security group.

---

# SSH Security

SSH access is restricted to the administrator's public IP.

Example:

```hcl
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
```

The `/32` means that only one IPv4 address is allowed.

This is significantly safer than:

```text
0.0.0.0/0
```

which would expose SSH to the entire internet.

If the administrator's public IP changes, the Terraform variable must be updated.

---

# Terraform Module Architecture

The project uses reusable Terraform modules.

```text
modules/
│
├── networking/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── security-groups/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── compute/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── database/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Networking Module

Responsible for:

* VPC
* Public subnet
* Private subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route tables
* Route table associations

---

## Security Groups Module

Responsible for:

* EC2 security group
* RDS security group
* HTTP access
* SSH access
* MySQL access

---

## Compute Module

Responsible for:

* Ubuntu AMI discovery
* EC2 instance
* Nginx installation
* Startup configuration
* EC2 outputs

---

## Database Module

Responsible for:

* RDS subnet group
* RDS MySQL instance
* Storage configuration
* Database configuration
* Database security association
* RDS outputs

---

# Project Structure

```text
terraform-aws-two-tier-application/
│
├── backend.tf
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── README.md
├── .gitignore
│
└── modules/
    │
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security-groups/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── compute/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── database/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Remote Terraform State

Terraform state is stored remotely in an Amazon S3 bucket.

Backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "hug-lagos-ibadan-terraform-state-saheed-2026"
    key    = "week3/terraform.tfstate"
    region = "eu-west-2"

    encrypt = true
  }
}
```

The state is separated from the Week 2 project using a different key:

```text
S3 Bucket
│
├── week2/
│   └── terraform.tfstate
│
└── week3/
    └── terraform.tfstate
```

This allows multiple projects to use the same S3 state bucket while maintaining separate Terraform state files.

---

# Variables

The infrastructure is configurable through Terraform variables.

Examples include:

```hcl
aws_region
project_name
vpc_cidr
public_subnet_cidr
private_subnet_cidr
private_subnet_cidr_2
availability_zone
availability_zone_2
instance_type
allowed_ssh_cidr
db_name
db_username
db_password
db_instance_class
allocated_storage
```

This makes the infrastructure reusable instead of hardcoding configuration values directly into resources.

---

# Deployment

## Prerequisites

Before deploying the project, install:

* Terraform >= 1.6
* AWS CLI
* An AWS account
* Appropriate AWS permissions
* Git

Verify Terraform:

```bash
terraform version
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

---

# 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

Move into the project:

```bash
cd terraform-aws-two-tier-application
```

---

# 2. Configure Terraform Variables

Create or update:

```text
terraform.tfvars
```

Example:

```hcl
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"

db_password = "YOUR-STRONG-PASSWORD"
```

Do not commit this file to GitHub.

The `.gitignore` contains:

```text
*.tfvars
```

to prevent Terraform variable files containing secrets from being committed.

---

# 3. Initialize Terraform

```bash
terraform init
```

Terraform will:

* Initialize the AWS provider
* Initialize the modules
* Configure the S3 backend
* Download required provider plugins

---

# 4. Format the Code

```bash
terraform fmt -recursive
```

---

# 5. Validate the Configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

# 6. Review the Execution Plan

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

The plan should show resources being created without unexpected destroys or modifications.

---

# 7. Deploy the Infrastructure

```bash
terraform apply
```

Review the plan and enter:

```text
yes
```

Terraform will provision the AWS infrastructure.

---

# 8. View Terraform Outputs

After deployment:

```bash
terraform output
```

Useful outputs include:

```text
vpc_id
public_subnet_id
private_subnet_id
db_instance_id
db_endpoint
db_port
db_name
```

---

# Application Verification

After the EC2 instance has finished initializing, retrieve its public IP:

```bash
terraform output
```

Then open:

```text
http://<EC2_PUBLIC_IP>
```

The browser should display:

```text
Two-Tier Application

Deployed with Terraform on AWS.

EC2 + Nginx is running successfully.
```

---

# Infrastructure Verification Checklist

After deployment, verify the following.

### VPC

* [ ] VPC exists
* [ ] CIDR is `10.0.0.0/16`
* [ ] Public subnet exists
* [ ] Two private subnets exist
* [ ] Internet Gateway exists
* [ ] NAT Gateway exists

### Routing

* [ ] Public subnet uses public route table
* [ ] Public route table routes internet traffic through IGW
* [ ] Private subnets use private route table
* [ ] Private route table routes outbound traffic through NAT Gateway

### EC2

* [ ] EC2 instance is running
* [ ] Ubuntu AMI was automatically selected
* [ ] Nginx is installed
* [ ] Nginx service is running
* [ ] Public IP is assigned
* [ ] HTTP is accessible

### Security

* [ ] HTTP 80 is publicly accessible
* [ ] SSH 22 is restricted to administrator IP
* [ ] RDS 3306 is not open to the internet
* [ ] RDS accepts traffic only from EC2 security group
* [ ] RDS is not publicly accessible

### RDS

* [ ] RDS instance is available
* [ ] RDS is using MySQL
* [ ] RDS is deployed using the private DB subnet group
* [ ] RDS public accessibility is disabled
* [ ] Storage encryption is enabled

---

# Screenshots / Project Evidence

The following screenshots should be captured as project evidence.

## 1. VPC

Capture the AWS VPC console showing:

* VPC
* Subnets
* Route tables
* Internet Gateway
* NAT Gateway

Suggested filename:

```text
screenshots/vpc.png
```

---

## 2. EC2

Capture the EC2 console showing:

* Instance ID
* Instance type
* Running state
* Public IPv4 address
* VPC
* Subnet

Suggested filename:

```text
screenshots/ec2.png
```

---

## 3. RDS

Capture the RDS console showing:

* Database identifier
* Engine
* Status
* Instance class
* Public access disabled

Suggested filename:

```text
screenshots/rds.png
```

---

## 4. Application

Open the EC2 public IP in a browser and capture the Nginx page.

Suggested filename:

```text
screenshots/application.png
```

---

# Important Security Considerations

This project intentionally demonstrates several security best practices.

### Database isolation

The database is deployed in private subnets.

```hcl
publicly_accessible = false
```

### Security group referencing

The RDS security group allows MySQL traffic from the EC2 security group rather than an IP range.

This creates a logical trust relationship:

```text
EC2-SG → RDS-SG :3306
```

### Restricted SSH

SSH is limited to one administrator IP:

```text
YOUR_PUBLIC_IP/32
```

### Remote state

Terraform state is stored remotely in S3 with encryption enabled.

### Sensitive variables

The database password is marked:

```hcl
sensitive = true
```

and the `.tfvars` file is excluded from Git.

---

# Terraform Commands Used

| Command                    | Purpose                         |
| -------------------------- | ------------------------------- |
| `terraform init`           | Initializes Terraform           |
| `terraform fmt -recursive` | Formats Terraform files         |
| `terraform validate`       | Validates configuration         |
| `terraform plan`           | Previews infrastructure changes |
| `terraform apply`          | Creates/updates infrastructure  |
| `terraform output`         | Displays Terraform outputs      |
| `terraform destroy`        | Removes project infrastructure  |

---

# Cleanup

When the project is no longer required, destroy the infrastructure:

```bash
terraform destroy
```

Terraform will display the resources that will be removed.

Confirm with:

```text
yes
```

This is particularly important for this project because resources such as:

* NAT Gateway
* Elastic IP
* RDS
* EC2

can incur AWS charges.

---

# Lessons Learned

This project provided practical experience with several important cloud engineering concepts.

### 1. Public vs Private Subnets

A public subnet has a route to an Internet Gateway.

A private subnet does not have a direct route to an Internet Gateway.

---

### 2. Internet Gateway vs NAT Gateway

An Internet Gateway allows resources with appropriate routing and public addressing to communicate with the internet.

A NAT Gateway allows resources in private subnets to initiate outbound internet connections without exposing those resources directly to inbound internet traffic.

---

### 3. Security Groups

Security groups provide resource-level network access control.

Instead of allowing database access from:

```text
0.0.0.0/0
```

the project allows:

```text
EC2 Security Group → RDS Security Group
```

---

### 4. Terraform Modules

Modules allow infrastructure components to be separated into reusable building blocks.

```text
Networking
Security
Compute
Database
```

This improves organization, maintainability, and reusability.

---

### 5. Terraform Data Sources

The project uses:

```hcl
data "aws_ami" "ubuntu"
```

to dynamically discover an appropriate Ubuntu AMI instead of hardcoding an AMI ID.

---

### 6. Remote State

Using an S3 backend allows Terraform state to be stored remotely rather than only on the local machine.

This becomes especially important when working collaboratively or managing infrastructure from multiple environments.

---

# Future Improvements

The current project is intentionally designed as a learning and portfolio project. A production implementation could be extended with:

* Application Load Balancer
* Auto Scaling Group
* Multiple EC2 instances
* HTTPS using ACM
* AWS WAF
* AWS Secrets Manager
* IAM roles instead of static credentials
* CloudWatch monitoring
* CloudWatch alarms
* VPC Flow Logs
* AWS Systems Manager Session Manager
* RDS Multi-AZ
* Read replicas
* Automated CI/CD using GitHub Actions
* Terraform environment separation
* Development/staging/production workspaces
* Private EC2 instances
* Bastionless administration using SSM
* Automated testing and security scanning
* AWS Backup
* GuardDuty
* Infrastructure cost monitoring

---

# Project Outcome

The completed infrastructure demonstrates how to build a secure two-tier AWS application environment using Infrastructure as Code.

The final architecture separates responsibilities into:

```text
                    TWO-TIER APPLICATION

                         INTERNET
                            │
                            ▼
                     Internet Gateway
                            │
                            ▼
                    ┌───────────────┐
                    │ Public Subnet │
                    │               │
                    │ EC2 + Nginx   │
                    └───────┬───────┘
                            │
                         :3306
                            │
                            ▼
                    ┌───────────────┐
                    │ Private       │
                    │ Subnets       │
                    │               │
                    │ RDS MySQL     │
                    └───────────────┘
```

The project demonstrates practical understanding of **AWS networking, infrastructure security, Terraform modules, remote state, compute provisioning, database deployment, and Infrastructure as Code**.

---

# Author

**Saheed Olatunde Ipaye**

Cloud / DevOps Engineer

AWS | Terraform | Docker | CI/CD | Cloud Infrastructure

---

# Community

This project was completed as part of the **HUG Lagos / HUG Ibadan Terraform Challenge**.

Special thanks to the community for creating opportunities to practice and demonstrate practical cloud engineering skills.
