resource "azurerm_storage_account" "static_storage" {
  name                     = var.static_web_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.type
  enable_https_traffic_only = true

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}