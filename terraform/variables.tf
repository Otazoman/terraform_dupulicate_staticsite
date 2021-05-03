variable "sitedomain" {
  default = "www.youredomain"
}
variable "rootdomain" {
  default = "youredomain"
}
variable "cert_name" {
  default = "youre-cert"
}

variable "google_cloud" {
  default = {
     project = "gcp-project-id"
     credentials = "~/.config/gcloud/sakey.json"
  }
}

variable "google_bucket" {
  default = {
    bucket_name   = "yourebucketname"
    region        = "asia"
    storage_class = "MULTI_REGIONAL"
    log_region    = "asia-northeast1"
    log_class     = "NEARLINE"
  }
}