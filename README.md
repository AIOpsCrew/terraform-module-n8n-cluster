# n8n Terraform Module for AWS Fargate

This Terraform module deploys n8n (workflow automation platform) to AWS Fargate in a highly available, production-ready configuration.

## Features

- **High Availability**: Multi-AZ deployment with Application Load Balancer
- **Scalable**: ECS Fargate with configurable CPU, memory, and task count
- **Secure**: Least privilege IAM, encrypted secrets, private subnets, SSL/TLS
- **Always Encrypted**: HTTPS enabled by default (self-signed cert or custom domain)
- **Serverless Database**: Aurora Serverless v2 PostgreSQL with auto-scaling
- **Cost-Effective**: Database scales down to 0.5 ACU during low usage
- **Optional Custom Domain**: Automatic ACM certificate creation and Route53 DNS
- **Monitoring**: CloudWatch logs, Performance Insights, and Enhanced Monitoring

## Architecture

See [architecture.drawio](architecture.drawio) for a detailed diagram (open with [draw.io](https://app.diagrams.net/)).

**Traffic Flow:**
- Internet Users → Internet Gateway → Application Load Balancer → ECS Fargate Tasks → Aurora Serverless v2 PostgreSQL
- ECS Tasks use NAT Gateways in public subnets for outbound internet access

**Multi-AZ Deployment:**
- Availability Zone A: Public subnet (NAT GW) + Private subnet (ECS) + DB subnet (Aurora instance)
- Availability Zone B: Public subnet (NAT GW) + Private subnet (ECS) + DB subnet (Aurora instance)
- Application Load Balancer spans both AZs for high availability

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.5.0
- AWS CLI configured
- Route53 hosted zone (if using custom domain)

## Quick Start

1. Clone this repository:
```bash
git clone <repository-url>
cd n8n-terraform-module
```

2. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit `terraform.tfvars` with your values:
```bash
# Update at minimum:
# - availability_zones (match your AWS region)
# - n8n_encryption_key (generate with: openssl rand -base64 32)
# - n8n_basic_auth_password
# - db_password
# - domain settings (if using custom domain)
```

4. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

5. Access n8n:
```bash
terraform output n8n_url
```

## Usage

### Basic Deployment (HTTP only)

```hcl
module "n8n" {
  source = "./module"

  environment        = "prod"
  availability_zones = ["us-east-1a", "us-east-1b"]

  n8n_encryption_key      = "your-encryption-key"
  n8n_basic_auth_password = "your-password"
  db_password             = "your-db-password"

  enable_custom_domain = false
}
```

### Production Deployment (HTTPS with custom domain)

```hcl
module "n8n" {
  source = "./module"

  environment        = "prod"
  availability_zones = ["us-east-1a", "us-east-1b"]

  n8n_encryption_key      = "your-encryption-key"
  n8n_basic_auth_password = "your-password"
  db_password             = "your-db-password"

  enable_custom_domain = true
  domain_name          = "n8n.example.com"
  route53_zone_id      = "Z1234567890ABC"
}
```

## Variables

See [variables.tf](variables.tf) for all available variables.

### Required Variables

| Name | Description |
|------|-------------|
| `environment` | Environment name (e.g., dev, staging, prod) |
| `availability_zones` | List of availability zones |
| `n8n_encryption_key` | Encryption key for n8n credentials |
| `db_password` | Database master password |

### Important Optional Variables

| Name | Default | Description |
|------|---------|-------------|
| `desired_count` | 2 | Number of n8n tasks for HA |
| `n8n_cpu` | 1024 | CPU units (1024 = 1 vCPU) |
| `n8n_memory` | 2048 | Memory in MB |
| `db_min_capacity` | 0.5 | Minimum Aurora ACU (0.5-128) |
| `db_max_capacity` | 2 | Maximum Aurora ACU (0.5-128) |
| `db_instance_count` | 2 | Aurora instances (2 for Multi-AZ) |
| `enable_custom_domain` | false | Enable custom domain with SSL |

## Outputs

| Name | Description |
|------|-------------|
| `n8n_url` | URL to access n8n |
| `alb_dns_name` | DNS name of the load balancer |
| `ecs_cluster_name` | Name of the ECS cluster |
| `rds_endpoint` | RDS database endpoint (sensitive) |

## Security Considerations

1. **Secrets**: All sensitive values are stored in AWS Secrets Manager
2. **Network**: ECS tasks and Aurora are in private subnets with no direct internet access
3. **IAM**: Roles follow least privilege principle
4. **Encryption**: Aurora encryption at rest enabled, HTTPS in transit always enabled
5. **Backups**: Aurora automated backups enabled with 7-day retention

### SSL/TLS Configuration

- **Without custom domain**: Uses self-signed certificate (browser warnings expected)
- **With custom domain**: Uses trusted ACM certificate (no warnings)
- All traffic is encrypted regardless of configuration
- HTTP automatically redirects to HTTPS

## Cost Estimation

Approximate monthly costs (us-east-1):
- ECS Fargate (2 tasks, 1vCPU, 2GB): ~$50
- Aurora Serverless v2 (0.5-2 ACU, 2 instances):
  - Minimum idle: ~$45/month (0.5 ACU × 2 instances)
  - Average workload: ~$90/month (1 ACU average)
  - Peak usage: ~$180/month (2 ACU × 2 instances)
- Application Load Balancer: ~$20
- NAT Gateways (2): ~$70
- Data transfer: Variable

**Total: ~$160-$230/month**
**Savings: Up to $100/month** during low-usage periods

## Maintenance

### Updating n8n Version

Update the `n8n_image` variable:
```hcl
n8n_image = "n8nio/n8n:1.0.0"  # Specify version
```

Then apply:
```bash
terraform apply
```

ECS will perform a rolling update with zero downtime.

### Scaling

**n8n Application - Horizontal scaling** (more tasks):
```hcl
desired_count = 4
```

**n8n Application - Vertical scaling** (more resources per task):
```hcl
n8n_cpu    = 2048  # 2 vCPU
n8n_memory = 4096  # 4GB
```

**Database - Auto-scaling** (Aurora Serverless v2 scales automatically):
```hcl
db_min_capacity = 0.5  # Scales down during low usage
db_max_capacity = 8    # Scales up under heavy load
```

Aurora will automatically scale between min and max capacity based on workload.

## Troubleshooting

### Check ECS Service Status
```bash
aws ecs describe-services \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --services $(terraform output -raw ecs_service_name)
```

### View Application Logs
```bash
aws logs tail /ecs/n8n-prod --follow
```

### Connect to Database
```bash
# Get RDS endpoint
terraform output rds_endpoint

# Connect (from within VPC or via bastion)
psql -h <endpoint> -U n8n_admin -d n8n
```

## License

MIT

## Support

For issues related to:
- **This Terraform module**: Open an issue in this repository
- **n8n application**: See [n8n documentation](https://docs.n8n.io/)
- **AWS services**: Consult [AWS documentation](https://docs.aws.amazon.com/)
