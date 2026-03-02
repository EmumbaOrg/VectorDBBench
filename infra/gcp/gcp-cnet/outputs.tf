output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.pgbench_subnets.id
}

output "cnet_ip_private" {
  description = "The private ip of the subnet"
  value       = google_compute_address.pgbench_address.address
}

output "cnet_ip_external_benchce" {
  description = "The external ip of the benchce"
  value       = google_compute_address.benchce_address.address
}

output "cnet_ip_external_dbce" {
  description = "The external ip of the dbce"
  value       = google_compute_address.dbce_address.address
}