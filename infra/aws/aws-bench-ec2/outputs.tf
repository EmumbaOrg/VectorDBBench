output "bench-sg" {
  description = "bench host sg"
  value       = aws_security_group.sg_bench_server.id
}

output "bench_eip" {
  description = "bench host eip"
  value       = aws_eip.bench_eip.public_ip
}


output "bench_key" {
  description = "bench key"
  value       = aws_key_pair.bench_key.key_name
}
