resource "google_storage_bucket" "logs-bucket" {
  name          = "${var.googlebucket.bucket_name}-logs"
  location      = var.googlebucket.log_region
  storage_class = var.googlebucket.log_class
  force_destroy = true
  labels = {
    project = var.googleCloud.project
  }
}

resource "google_storage_bucket_acl" "logs-bucket_iam" {
  bucket = google_storage_bucket.logs-bucket.name
  role_entity = [
    "WRITER:group-cloud-storage-analytics@google.com"
  ]
  default_acl = "projectprivate"
}

resource "google_storage_bucket_iam_binding" "logs-bucket_binding" {
  bucket  = google_storage_bucket.logs-bucket.name
  role    = "roles/storage.admin"
  members = ["serviceAccount:${var.service_account}"]
}

resource "google_storage_bucket" "bucket" {
  name          = var.googlebucket.bucket_name
  location      = var.googlebucket.region
  storage_class = var.googlebucket.storage_class
  force_destroy = true
  labels = {
    project = var.googleCloud.project
  }
  versioning {
    enabled = true
  }
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  logging {
    log_bucket = "${var.googlebucket.bucket_name}-logs"
  }
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "staticweb_bucket_iam_binding_object_viewer" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.legacyObjectReader"
  members = ["allUsers"]
}
