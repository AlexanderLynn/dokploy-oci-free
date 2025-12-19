output "dokploy_main_public_ip" {
  description = "Public IP of the main Dokploy instance"
  value       = oci_core_instance.dokploy_main.public_ip
}

output "dokploy_dashboard_url" {
  description = "URL to access the Dokploy dashboard"
  value       = "http://${oci_core_instance.dokploy_main.public_ip}:3000"
}

output "dokploy_worker_public_ips" {
  description = "Public IPs of the Dokploy worker instances"
  value       = oci_core_instance.dokploy_worker[*].public_ip
}
