variable "site_domain" {
  default = "www.youredomain"
}
variable "root_domain" {
  default = "youredomain"
}
variable "cert_name" {
  default = "youre-cert"
}

variable "googleCloud" {
  default = {
     project = "gcp-project-id"
     credentials = "~/.secret/gcloud/serviceaccount.json"
  }
}

variable "googlebucket" {
  default = {
    bucket_name   = "yourebucketname"
    region        = "asia"
    storage_class = "MULTI_REGIONAL"
    log_region    = "asia-northeast1"
    log_class     = "NEARLINE"
  }
}