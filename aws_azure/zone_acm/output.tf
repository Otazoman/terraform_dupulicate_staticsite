output "domain_zone" {
  value = data.aws_route53_zone.zone.zone_id
}
output "cert_arn" {
  value = aws_acm_certificate.cert.arn
}