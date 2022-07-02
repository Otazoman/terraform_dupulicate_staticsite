resource "null_resource" "delete_a_records" {
  provisioner "local-exec" {
    command = "/bin/bash ./sh/alias_arecord_delete.sh ${var.root_domain}"
  }
}

resource "aws_route53_health_check" "cdn_healthcheck" {
  reference_name   = "${var.bucket_name}_check"
  fqdn              = var.cloudfront_domain
  failure_threshold = "3"
  type              = "HTTPS"
  port              = 443
  request_interval  = "30"
  tags = {
    Name = "${var.bucket_name}-web-check"
  }
  depends_on = [null_resource.delete_a_records]
}

resource "aws_route53_record" "main_alias_ipv4" {
  zone_id = var.dns_zone
  name = "main.${var.root_domain}"
  type = "A"
  alias {
    name = var.cloudfront_domain
    zone_id = var.cloudfront_id
    evaluate_target_health = false
  }
  depends_on = [null_resource.delete_a_records]
}

resource "aws_route53_record" "root_domain" {
  zone_id = var.dns_zone
  name = var.root_domain
  type = "A"
  health_check_id = aws_route53_health_check.cdn_healthcheck.id
  set_identifier = "${var.bucket_name}-ipv4-main"
  failover_routing_policy {
    type = "PRIMARY"
  }
  alias {
    name = aws_route53_record.main_alias_ipv4.name
    zone_id = var.dns_zone
    evaluate_target_health = true
  }
  depends_on = [null_resource.delete_a_records]
}

resource "aws_route53_record" "www_domain" {
  zone_id = var.dns_zone
  name = var.site_domain
  type = "A"
  health_check_id = aws_route53_health_check.cdn_healthcheck.id
  set_identifier = "${var.bucket_name}-www-ipv4-main"
  failover_routing_policy {
    type = "PRIMARY"
  }
  alias {
    name = aws_route53_record.main_alias_ipv4.name
    zone_id = var.dns_zone
    evaluate_target_health =  true
  }
  depends_on = [null_resource.delete_a_records]
}

resource "aws_route53_record" "azure_root_domain" {
  zone_id = var.dns_zone
  name = var.root_domain
  type = "A"
  ttl = "60"
  records = [var.azure_ipv4_addr]
  set_identifier = "${var.bucket_name}-ipv4-sub"
  failover_routing_policy {
    type = "SECONDARY"
  }
  depends_on = [null_resource.delete_a_records]
}

resource "aws_route53_record" "azure_www_domain" {
  zone_id = var.dns_zone
  name = var.site_domain
  type = "A"
  ttl = "60"
  records = [var.azure_ipv4_addr]
  set_identifier = "${var.bucket_name}-www-ipv4-sub"
  failover_routing_policy {
    type = "SECONDARY"
  }
  depends_on = [null_resource.delete_a_records]
}