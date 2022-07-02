resource "google_compute_global_address" "lb_v4_address" {
  name = "lb-v4-address"
  ip_version = "IPV4"
}

resource "google_compute_global_address" "lb_v6_address" {
  name       = "lb-v6-address"
  ip_version = "IPV6"
}

resource "null_resource" "delete_aliasrecords" {
  provisioner "local-exec" {
    command = "/bin/bash ./sh/alias_arecord_delete.sh ${var.root_domain}"
  }
  depends_on = [
    google_compute_global_address.lb_v4_address,
    google_compute_global_address.lb_v6_address
  ]
}

resource "aws_route53_record" "gcp_root_domain" {
  zone_id = var.dns_zone
  name = var.root_domain
  type = "A"
  ttl = "60"
  records = [google_compute_global_address.lb_v4_address.address]
  depends_on = [null_resource.delete_aliasrecords]
}

resource "aws_route53_record" "gcp_www_domain" {
  zone_id = var.dns_zone
  name = var.site_domain
  type = "A"
  ttl = "60"
  records = [google_compute_global_address.lb_v4_address.address]
  depends_on = [null_resource.delete_aliasrecords]
}