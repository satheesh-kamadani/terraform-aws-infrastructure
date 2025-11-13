# 🌩️ AWS Infrastructure with Terraform

This project demonstrates how to **provision and manage AWS infrastructure using Terraform** — following Infrastructure-as-Code (IaC) best practices.

It creates a **complete, production-style environment** including a custom VPC, public subnets, EC2 instances, a load balancer, and an S3 bucket.  
This setup can serve as a solid foundation for deploying web applications on AWS.

---

## 🚀 Project Overview

### Resources Provisioned
| Category | Resource | Description |
|-----------|-----------|-------------|
| **Networking** | VPC | Custom VPC with CIDR block `10.0.0.0/16` |
|  | Subnets | Two public subnets in different AZs (`us-east-1a`, `us-east-1b`) |
|  | Internet Gateway | Provides internet access for public subnets |
|  | Route Table | Configured to route internet traffic via IGW |
| **Security** | Security Group | Allows inbound HTTP (80) and SSH (22) |
| **Compute** | EC2 Instances | Two t2.micro web servers with user data scripts |
| **Load Balancer** | Application Load Balancer | Distributes HTTP traffic to both EC2 instances |
| **Storage** | S3 Bucket | Simple demo bucket for static storage |
| **Outputs** | ALB DNS Name | Terraform output displays the DNS endpoint of the load balancer |

---

## Screenshots
- Web server 1 - screenshots/server1.png
- Web server 2 - screenshots/server2.png

## 🧱 Architecture Diagram

![alt text](image.png)

## 1.Clone the repo
``` bash
git clone https://github.com/satheesh-kamadani/terraform-aws-infrastructure.git
cd terraform-aws-infrastructure
```
## 2.Initialize Terraform
``` bash
  terraform init
```
## 3.Preview the plan
``` bash
terraform plan
```
## 4.Apply the configuration
``` bash
terraform apply -auto-approve
```
## 5.Get the Load Balancer DNS
``` bash
terraform output loadbalancerdns
```
## 6.Access your web app
- Open the DNS URL in your browser to see your running EC2 web servers behind the ALB.

## 7.Cleanup
``` bash
terraform destroy -auto-approve
```


