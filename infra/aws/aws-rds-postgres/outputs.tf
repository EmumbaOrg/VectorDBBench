# POSTGRES OBJECT
output "postgres" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}