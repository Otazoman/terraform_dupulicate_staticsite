provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
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
  bucket_name = var.bucket_name
  acm_cert    = module.zone_acm.cert_arn
  dns_zone    = module.zone_acm.domain_zone
  depends_on  = [module.zone_acm]
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = "prod"
  }
}

module "azurestatic" {
  source                = "./azurestatic"
  root_domain           = var.root_domain
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  storage_name          = var.storage_name
  type                  = var.type
  static_web_name       = var.static_web_name
  virutual_network_name = var.virutual_network_name
  pfx_filename          = var.pfx_filename
  cert_passwd           = var.cert_passwd
}

module "failoverdns" {
  source            = "./failoverdns"
  root_domain       = var.root_domain
  site_domain       = var.site_domain
  bucket_name       = var.bucket_name
  dns_zone          = module.zone_acm.domain_zone
  cloudfront_id     = module.awsstatic.cloudfront_alias_id
  cloudfront_domain = module.awsstatic.cloudfront_alias_name
  azure_ipv4_addr   = module.azurestatic.static_ip
  depends_on        = [module.azurestatic]
}