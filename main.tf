module "n8n" {
  source = "./module"

  # General Configuration
  environment  = var.environment
  project_name = var.project_name

  # Network Configuration
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  # ECS/Fargate Configuration
  n8n_image     = var.n8n_image
  n8n_cpu       = var.n8n_cpu
  n8n_memory    = var.n8n_memory
  desired_count = var.desired_count

  # n8n Configuration
  n8n_encryption_key      = var.n8n_encryption_key
  n8n_basic_auth_active   = var.n8n_basic_auth_active
  n8n_basic_auth_user     = var.n8n_basic_auth_user
  n8n_basic_auth_password = var.n8n_basic_auth_password

  # Database Configuration (Aurora Serverless v2)
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  db_min_capacity            = var.db_min_capacity
  db_max_capacity            = var.db_max_capacity
  db_instance_count          = var.db_instance_count
  db_backup_retention_period = var.db_backup_retention_period

  # Domain Configuration
  enable_custom_domain = var.enable_custom_domain
  domain_name          = var.domain_name
  route53_zone_id      = var.route53_zone_id
  certificate_arn      = var.certificate_arn

  # Tags
  tags = var.tags
}
