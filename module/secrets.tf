# Secrets Manager - n8n Encryption Key
resource "aws_secretsmanager_secret" "n8n_encryption_key" {
  name_prefix             = "${var.project_name}-${var.environment}-encryption-key-"
  description             = "n8n encryption key for credentials"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-encryption-key"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "n8n_encryption_key" {
  secret_id     = aws_secretsmanager_secret.n8n_encryption_key.id
  secret_string = var.n8n_encryption_key
}

# Secrets Manager - Database Password
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix             = "${var.project_name}-${var.environment}-db-password-"
  description             = "RDS database password for n8n"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db-password"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# Secrets Manager - n8n Basic Auth Password (optional)
resource "aws_secretsmanager_secret" "n8n_basic_auth_password" {
  count                   = var.n8n_basic_auth_active ? 1 : 0
  name_prefix             = "${var.project_name}-${var.environment}-basic-auth-password-"
  description             = "n8n basic auth password"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-basic-auth-password"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "n8n_basic_auth_password" {
  count         = var.n8n_basic_auth_active ? 1 : 0
  secret_id     = aws_secretsmanager_secret.n8n_basic_auth_password[0].id
  secret_string = var.n8n_basic_auth_password
}
