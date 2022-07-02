resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virutual_network_name}_subnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "${var.virutual_network_name}_frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "${var.virutual_network_name}_backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.virutual_network_name}_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  application_gateway_name       = "${azurerm_virtual_network.vnet.name}_appgateway"
  gateway_configuration_name     = "${azurerm_virtual_network.vnet.name}_ipconfiguration"
  fqdn                           = "${replace("${azurerm_storage_account.static_storage.primary_web_endpoint}","/(?i)https://([^/]+).*/*/","$1")}"
  certificate_name               = "${azurerm_virtual_network.vnet.name}_cert"
  cert_path                      = "./cert/${var.pfx_filename}.pfx" 
  cert_password                  = var.cert_passwd
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}_beap"
  frontend_https_port_name       = "${azurerm_virtual_network.vnet.name}_https-feport"
  frontend_http_port_name        = "${azurerm_virtual_network.vnet.name}_http-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}_feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}_be-htst"
  listener_https_name            = "${azurerm_virtual_network.vnet.name}_httpslstn"
  listener_http_name             = "${azurerm_virtual_network.vnet.name}_httplstn"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}_rdrcfg"
  request_redirect_rule_name      = "${azurerm_virtual_network.vnet.name}_rqrdrt"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}_rqrt"
}

resource "azurerm_application_gateway" "network" {
  name                = local.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_configuration_name
    subnet_id = azurerm_subnet.frontend.id
  }

  ssl_certificate {
    name      = local.certificate_name
    data      = filebase64(local.cert_path)
    password  = local.cert_password
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = local.frontend_https_port_name
    port = 443
  }
  frontend_port {
    name = local.frontend_http_port_name
    port = 80
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [local.fqdn]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_https_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_https_port_name
    protocol                       = "Https"
    ssl_certificate_name           = local.certificate_name
  }
  http_listener {
    name                           = local.listener_http_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_http_port_name
    protocol                       = "Http"
  }

  redirect_configuration {
    name                       = local.redirect_configuration_name
    redirect_type              = "Permanent"
    target_listener_name       = local.listener_https_name
    include_path               = true
    include_query_string       = true
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_https_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 200
  }
  request_routing_rule {
    name                       = local.request_redirect_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_http_name
    redirect_configuration_name = local.redirect_configuration_name
    priority                   = 100
  }
  enable_http2               = true
}