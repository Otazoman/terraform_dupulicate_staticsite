resource "google_compute_backend_bucket" "bucket_backend" {
  name        = "${var.name}-backend"
  bucket_name = google_storage_bucket.bucket.name
}

resource "google_compute_url_map" "urlmap" {
  name        = "${var.name}-https-site"
  description = "URL map for ${var.name}"
  default_service = google_compute_backend_bucket.bucket_backend.self_link
  host_rule {
    hosts        = ["*"]
    path_matcher = "all"
  }
  path_matcher {
    name            = "all"
    default_service = google_compute_backend_bucket.bucket_backend.self_link
    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.bucket_backend.self_link
    }
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name        = "${var.name}-proxy"
  url_map     = google_compute_url_map.urlmap.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.naked_lb_cert.id,
    google_compute_managed_ssl_certificate.www_lb_cert.id
  ]
}

resource "google_compute_global_forwarding_rule" "https_ipv4" {
  name   = "${var.name}-v4-fwdrule"
  target = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.lb_v4_address.address
}

resource "google_compute_global_forwarding_rule" "https_ipv6" {
  name   = "${var.name}-v6-fwdrule"
  target = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.lb_v6_address.address
}

resource "google_compute_url_map" "http_redirect" {
  name = "${var.name}-redirect"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_default" {
  name     = "${var.name}-https-redirect-proxy"
  url_map  = google_compute_url_map.http_redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http_ipv4" {
  name       = "${var.name}-http-v4-fwdrule"
  target     = google_compute_target_http_proxy.http_default.self_link
  ip_address = google_compute_global_address.lb_v4_address.address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "http_ipv6" {
  name       = "${var.name}-http-v6-fwdrule"
  target     = google_compute_target_http_proxy.http_default.self_link
  ip_address = google_compute_global_address.lb_v6_address.address
  port_range = "80"
}

resource "null_resource" "check_complete_lb" {
  provisioner "local-exec" {
    command = "/bin/bash ./sh/gcp_cert_check.sh ${var.root_domain}"
  }
  depends_on = [
    aws_route53_record.gcp_root_domain,
    aws_route53_record.gcp_www_domain
  ]
}