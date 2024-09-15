// AWS
variable "site_domain" {
  default = "www.yourdomain"
}
variable "root_domain" {
  default = "yourdomain"
}
variable "bucket_name" {
  default = "yourbucketname"
}
variable "cert_name" {
  default = "youre-cert"
}
// Azure
variable "resource_group_name" {
  default = "rg_multicloud_static_site"
}
variable "location" {
  default = "japaneast"
}
variable "storage_name" {
  default = "yourstoragename"
}
variable "type" {
  default = "GZRS"
}
variable "static_web_name" {
  default = "yourstaticwebname"
}
variable "virutual_network_name" {
  default = "yourvnetname"
}
variable "pfx_filename" {
  default = "yourpfxfilename"
}
variable "cert_passwd" {
  default = "yourcertpasswd"
}