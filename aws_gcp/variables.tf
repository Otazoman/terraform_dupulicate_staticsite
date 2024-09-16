variable "site_domain" {
  default = "www.example.com"
}
variable "root_domain" {
  default = "example.com"
}
variable "cert_name" {
  default = "example"
}

variable "googleCloud" {
  default = {
    project         = "yourprojectname"
    credentials     = "yourserviceaccount json file path"
    service_account = "yourserviceaccount"
  }
}

variable "googlebucket" {
  default = {
    bucket_name   = "yourbucketname"
    region        = "asia"
    storage_class = "MULTI_REGIONAL"
    log_region    = "asia-northeast1"
    log_class     = "NEARLINE"
  }
}
