# General Configuration
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "n8n"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# ECS/Fargate Configuration
variable "n8n_image" {
  description = "Docker image for n8n"
  type        = string
  default     = "n8nio/n8n:latest"
}

variable "n8n_cpu" {
  description = "CPU units for n8n task (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "n8n_memory" {
  description = "Memory for n8n task in MB"
  type        = number
  default     = 2048
}

variable "desired_count" {
  description = "Desired number of n8n tasks"
  type        = number
  default     = 2
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
  default     = true
}

variable "n8n_basic_auth_user" {
  description = "Basic auth username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "n8n_basic_auth_password" {
  description = "Basic auth password"
  type        = string
  sensitive   = true
}

# Database Configuration (Aurora Serverless v2)
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "n8n"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "n8n_admin"
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
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum ACU (Aurora Capacity Units) for serverless v2 scaling (0.5 to 128)"
  type        = number
  default     = 2
}

variable "db_instance_count" {
  description = "Number of Aurora instances (1 for single-AZ, 2+ for Multi-AZ)"
  type        = number
  default     = 2
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

# Domain Configuration
variable "enable_custom_domain" {
  description = "Enable custom domain with SSL"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for n8n"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for domain"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of ACM certificate (if not provided, one will be created)"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
