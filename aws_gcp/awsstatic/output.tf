output "cloudfront_alias_id" {
  value = aws_cloudfront_distribution.static-site-dst.hosted_zone_id
}

output "cloudfront_alias_name" {
  value = aws_cloudfront_distribution.static-site-dst.domain_name
}

output "cloudfront_dist_id" {
  value = aws_cloudfront_distribution.static-site-dst.id
}