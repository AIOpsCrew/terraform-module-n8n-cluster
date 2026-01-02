# General Configuration
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

# ECS/Fargate Configuration
variable "n8n_image" {
  description = "Docker image for n8n"
  type        = string
}

variable "n8n_cpu" {
  description = "CPU units for n8n task"
  type        = number
}

variable "n8n_memory" {
  description = "Memory for n8n task in MB"
  type        = number
}

variable "desired_count" {
  description = "Desired number of n8n tasks"
  type        = number
}

# n8n Configuration
variable "n8n_encryption_key" {
  description = "Encryption key for n8n credentials"
  type        = string
  sensitive   = true
}

variable "n8n_basic_auth_active" {
  description = "Enable basic auth for n8n"
  type        = bool
}

variable "n8n_basic_auth_user" {
  description = "Basic auth username"
  type        = string
  sensitive   = true
}

variable "n8n_basic_auth_password" {
  description = "Basic auth password"
  type        = string
  sensitive   = true
}

# Optional AWS Integrations for n8n
variable "enable_n8n_aws_integrations" {
  description = "Enable AWS service integrations for n8n workflows"
  type        = bool
  default     = false
}

variable "n8n_s3_bucket_arns" {
  description = "List of S3 bucket ARNs that n8n can access"
  type        = list(string)
  default     = []
}

variable "n8n_ses_from_addresses" {
  description = "List of email addresses n8n can send from via SES"
  type        = list(string)
  default     = []
}

# Database Configuration (Aurora Serverless v2)
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_min_capacity" {
  description = "Minimum ACU (Aurora Capacity Units) for serverless v2 scaling (0.5 to 128)"
  type        = number
}

variable "db_max_capacity" {
  description = "Maximum ACU (Aurora Capacity Units) for serverless v2 scaling (0.5 to 128)"
  type        = number
}

variable "db_instance_count" {
  description = "Number of Aurora instances (1 for single-AZ, 2+ for Multi-AZ)"
  type        = number
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
}

variable "db_kms_key_id" {
  description = "KMS key ID for encryption (leave empty for default)"
  type        = string
  default     = ""
}

# Domain Configuration
variable "enable_custom_domain" {
  description = "Enable custom domain with SSL"
  type        = bool
}

variable "domain_name" {
  description = "Custom domain name for n8n"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of existing ACM certificate"
  type        = string
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
}
