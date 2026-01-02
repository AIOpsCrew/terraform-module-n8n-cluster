# ACM Certificate - Only create if custom domain is enabled and no certificate ARN is provided
resource "aws_acm_certificate" "main" {
  count             = var.enable_custom_domain && var.certificate_arn == "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-cert"
      Environment = var.environment
    }
  )
}

# Route53 DNS Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = var.enable_custom_domain && var.certificate_arn == "" ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Certificate Validation
resource "aws_acm_certificate_validation" "main" {
  count                   = var.enable_custom_domain && var.certificate_arn == "" ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
