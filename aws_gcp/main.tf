provider "aws" {
  region = "ap-northeast-1"
}
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

provider "google" {
  project     = var.googleCloud.project
  credentials = file(var.googleCloud.credentials)
}

provider "google-beta" {
  project     = var.googleCloud.project
  credentials = file(var.googleCloud.credentials)
}

module "zone_acm" {
  source      = "./zone_acm"
  root_domain = var.root_domain
  providers = {
    aws = aws.use1
  }
}

module "awsstatic" {
  source      = "./awsstatic"
  root_domain = var.root_domain
  site_domain = var.site_domain
  bucket_name = var.root_domain
  acm_cert    = module.zone_acm.cert_arn
  dns_zone    = module.zone_acm.domain_zone
  depends_on  = [module.zone_acm]
}

module "gcpstatic" {
  source          = "./gcpstatic"
  googleCloud     = var.googleCloud
  googlebucket    = var.googlebucket
  name            = var.cert_name
  root_domain     = var.root_domain
  site_domain     = var.site_domain
  dns_zone        = module.zone_acm.domain_zone
  service_account = var.googleCloud.service_account
  depends_on      = [module.awsstatic]
}

module "failoverdns" {
  source            = "./failoverdns"
  root_domain       = var.root_domain
  site_domain       = var.site_domain
  bucket_name       = var.cert_name
  dns_zone          = module.zone_acm.domain_zone
  cloudfront_id     = module.awsstatic.cloudfront_alias_id
  cloudfront_domain = module.awsstatic.cloudfront_alias_name
  gcp_ipv4_addr     = module.gcpstatic.gcp_ipv4
  gcp_ipv6_addr     = module.gcpstatic.gcp_ipv6
  depends_on        = [module.gcpstatic]
}
