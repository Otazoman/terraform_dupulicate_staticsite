output "gcp_ipv4" {
  value = google_compute_global_address.lb_v4_address.address
}

output "gcp_ipv6" {
  value = google_compute_global_address.lb_v6_address.address
}