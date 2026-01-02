# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform module for deploying n8n (workflow automation platform). The module should provide reusable infrastructure-as-code for deploying n8n across different cloud providers or environments.

## Terraform Module Development

### Common Commands

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate module configuration
terraform validate

# Initialize Terraform (in examples or test directories)
terraform init

# Plan infrastructure changes (in examples)
terraform plan

# Apply infrastructure changes (in examples)
terraform apply

# Destroy infrastructure (in examples)
terraform destroy
```

### Module Testing

If using terratest or terraform-compliance:
```bash
# Run Go-based tests (terratest)
go test -v ./test/...

# Run compliance tests
terraform-compliance -f features/ -p plan.out
```

### Linting and Validation

```bash
# Run tflint
tflint --init
tflint

# Check for security issues with tfsec
tfsec .

# Validate with checkov
checkov -d .
```

## Architecture

### Module Structure

This module deploys n8n to AWS Fargate in a highly available configuration:

```
/
├── main.tf           # Root module - calls the n8n module
├── variables.tf      # Root module input variables
├── outputs.tf        # Root module outputs
└── module/           # n8n module implementation
    ├── versions.tf          # Terraform and provider version constraints
    ├── variables.tf         # Module input variables
    ├── outputs.tf           # Module outputs
    ├── vpc.tf              # VPC, subnets, NAT gateways, route tables
    ├── security_groups.tf  # Security groups for ALB, ECS, and RDS
    ├── iam.tf              # IAM roles and policies (least privilege)
    ├── rds.tf              # PostgreSQL database for n8n
    ├── ecs.tf              # ECS cluster, task definition, and service
    ├── alb.tf              # Application Load Balancer and target groups
    ├── acm.tf              # ACM certificate for HTTPS (optional)
    ├── route53.tf          # DNS records (optional)
    ├── cloudwatch.tf       # CloudWatch log groups
    └── secrets.tf          # Secrets Manager for sensitive values
```

### Deployment Architecture

**High Availability:**
- Multi-AZ deployment across 2+ availability zones
- ECS Service with configurable `desired_count` (default: 2 tasks)
- Multi-AZ RDS with automated backups
- NAT Gateway per AZ for redundancy
- ALB with cross-zone load balancing

**Network Architecture:**
- Public subnets: ALB, NAT Gateways
- Private subnets: ECS tasks, RDS database
- Security groups enforce least privilege:
  - ALB: allows 80/443 from internet, egress to ECS on 5678
  - ECS: allows 5678 from ALB, egress to RDS on 5432 and internet on 80/443
  - RDS: allows 5432 from ECS only

**IAM Least Privilege:**
- `ecs_task_execution` role: pulls images, writes logs, reads secrets
- `ecs_task` role: minimal permissions for n8n app
- Optional AWS integrations policy for S3/SES access (disabled by default)

**Security:**
- All sensitive values stored in Secrets Manager
- RDS encryption at rest enabled
- SSL/TLS in transit via HTTPS (when custom domain enabled)
- Deletion protection on RDS
- Private subnets for all application resources

**Custom Domain (Optional):**
- Set `enable_custom_domain = true`
- Provide `domain_name` and `route53_zone_id`
- Module creates ACM certificate with DNS validation
- HTTP redirects to HTTPS
- Or provide existing `certificate_arn`

### Key Configuration Points

**Scaling:**
- Adjust `desired_count` for horizontal scaling of n8n tasks
- Modify `n8n_cpu` and `n8n_memory` for vertical scaling
- Aurora Serverless v2 auto-scales between `db_min_capacity` and `db_max_capacity`

**Database (Aurora Serverless v2):**
- PostgreSQL 15.8 compatible (Aurora)
- Auto-scaling from 0.5 to 128 ACU (Aurora Capacity Units)
- Multi-AZ enabled by default (2 instances)
- Performance Insights and Enhanced Monitoring enabled
- 7-day backup retention (configurable)
- CloudWatch logs enabled for PostgreSQL logs
- Cost-effective: scales down during low usage, scales up under load

**n8n Configuration:**
- Container runs on port 5678
- Workflow data stored in Aurora PostgreSQL
- Encryption key managed via Secrets Manager
- Optional basic auth for additional security
- Health checks on `/healthz` endpoint

### Important Files for Modifications

- **module/ecs.tf:151-183**: n8n environment variables and secrets configuration
- **module/security_groups.tf**: Modify if additional ports/protocols needed
- **module/iam.tf:77-103**: Add AWS service permissions for n8n workflows
- **module/alb.tf:63**: SSL policy configuration
- **module/rds.tf**: Database version and performance settings
