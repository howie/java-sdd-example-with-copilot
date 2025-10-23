terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # 這裡的值會在實際部署時設定
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# MySQL Database
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version            = "8.0.21"
  
  administrator_login    = var.database_admin_login
  administrator_password = var.database_admin_password

  sku_name = "B_Standard_B1s"

  storage {
    size_gb = 20
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "database" {
  name                = "thsr_booking"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation          = "utf8mb4_unicode_ci"
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                = "Basic"
  admin_enabled      = true
  tags               = var.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                = "env-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Container App
resource "azurerm_container_app" "app" {
  name                         = "app-${var.project_name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name         = azurerm_resource_group.rg.name
  revision_mode               = "Single"

  template {
    container {
      name   = "thsr-booking"
      image  = "${azurerm_container_registry.acr.login_server}/${var.project_name}:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      }

      env {
        name  = "MYSQL_URL"
        value = "jdbc:mysql://${azurerm_mysql_flexible_server.mysql.fqdn}:3306/${azurerm_mysql_flexible_database.database.name}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port     = 8080
    transport       = "http"
  }

  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  tags = var.tags
}