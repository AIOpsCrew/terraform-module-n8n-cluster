output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.n8n.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.n8n.alb_zone_id
}

output "n8n_url" {
  description = "URL to access n8n"
  value       = module.n8n.n8n_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.n8n.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.n8n.ecs_service_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.n8n.rds_endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.n8n.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.n8n.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.n8n.public_subnet_ids
}
