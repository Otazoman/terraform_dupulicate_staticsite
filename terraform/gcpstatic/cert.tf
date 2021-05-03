resource "google_compute_managed_ssl_certificate" "naked_lb_cert" {
  name = "${var.name}-cert"
  managed {
    domains = [var.root_domain]
  }
}

resource "google_compute_managed_ssl_certificate" "www_lb_cert" {
  name = "www-${var.name}-cert"
  managed {
    domains = [var.site_domain]
  }
}