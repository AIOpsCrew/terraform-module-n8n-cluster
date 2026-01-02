# Self-signed certificate for ALB when no custom domain is configured
# This encrypts traffic but will show browser warnings (not trusted)

# Generate private key
resource "tls_private_key" "alb" {
  count     = var.enable_custom_domain ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate self-signed certificate
resource "tls_self_signed_cert" "alb" {
  count           = var.enable_custom_domain ? 0 : 1
  private_key_pem = tls_private_key.alb[0].private_key_pem

  subject {
    common_name  = aws_lb.main.dns_name
    organization = var.project_name
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [
    aws_lb.main.dns_name
  ]
}

# Upload self-signed certificate to ACM
resource "aws_acm_certificate" "self_signed" {
  count            = var.enable_custom_domain ? 0 : 1
  private_key      = tls_private_key.alb[0].private_key_pem
  certificate_body = tls_self_signed_cert.alb[0].cert_pem

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-self-signed-cert"
      Environment = var.environment
      Type        = "Self-Signed"
    }
  )
}
