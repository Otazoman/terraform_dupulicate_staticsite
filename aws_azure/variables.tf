// AWS
variable "site_domain" {
  default = "www.example.com"
}
variable "root_domain" {
  default = "example.com"
}
variable "bucket_name" {
  default = "example.com"
}
variable "cert_name" {
  default = "exampleazure"
}
// Azure
variable "resource_group_name" {
  default = "rg_multicloud_static_site"
}
variable "location" {
  default = "japaneast"
}
variable "storage_name" {
  default = "example_static_web_storage"
}
variable "type" {
  default = "GZRS"
}
variable "static_web_name" {
  default = "examplestaticweb"
}
variable "virutual_network_name" {
  default = "example_staticsiteweb_vnet"
}
variable "pfx_filename" {
  default = "example"
}
variable "cert_passwd" {
  default = "example"
}
