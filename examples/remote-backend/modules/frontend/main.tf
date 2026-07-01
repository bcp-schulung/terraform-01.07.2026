# ─── App Service ──────────────────────────────────────────────────────────────

# Stable random suffix — App Service hostnames must be globally unique
resource "random_id" "suffix" {
  byte_length = 3
  keepers = {
    prefix              = var.prefix
    resource_group_name = var.resource_group_name
  }
}

resource "azurerm_service_plan" "main" {
  name                = "${var.prefix}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "S1"
  tags                = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "${var.prefix}-app-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
  }
}

# ─── Application Gateway with WAF v2 ──────────────────────────────────────────

resource "azurerm_public_ip" "agw" {
  name                = "${var.prefix}-pip-agw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "${var.prefix}-waf-policy"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

locals {
  backend_pool_name  = "${var.prefix}-backend-pool"
  http_setting_name  = "${var.prefix}-http-settings"
  listener_name      = "${var.prefix}-listener-http"
  routing_rule_name  = "${var.prefix}-routing-rule"
  fe_ip_config_name  = "${var.prefix}-fe-ip-config"
  fe_port_name       = "${var.prefix}-fe-port-80"
  agw_ip_config_name = "${var.prefix}-agw-ip-config"
}

resource "azurerm_application_gateway" "main" {
  name                = "${var.prefix}-agw"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = local.agw_ip_config_name
    subnet_id = var.agw_subnet_id
  }

  frontend_port {
    name = local.fe_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.fe_ip_config_name
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  # Backend targets the App Service on HTTPS
  backend_address_pool {
    name  = local.backend_pool_name
    fqdns = [azurerm_linux_web_app.main.default_hostname]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.fe_ip_config_name
    frontend_port_name             = local.fe_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.routing_rule_name
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
