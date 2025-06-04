output "db-sg" {
  description = "db host sg"
  value       = aws_security_group.sg_db_server.id
}

output "db_eip" {
  description = "db host eip"
  value       = aws_eip.db_eip.public_ip
}


output "db_key" {
  description = "db key"
  value       = aws_key_pair.db_key.key_name
}
