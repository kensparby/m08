terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "rg-be-tf-ks"         # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
  #   storage_account_name = "sabeks1390ornp4nk6"   # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
  #   container_name       = "kstfstate"                 # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
  #   key                  = "backend.terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  # }
}

provider "azurerm" {
  subscription_id = "efc1e7b1-5729-4eea-b33e-12cc6b1c0183"
  features {
    # key_vault {
    #   purge_soft_delete_on_destroy    = true
    #   recover_soft_deleted_key_vaults = true
    # }
  }
}

resource "random_string" "random_string" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.sa_name}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_blob" "index_html" {
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = local_file.index_html.filename
}

resource "local_file" "index_html" {
  filename = var.index_document
  content  = "<h1>Hello World</h1>"
}

resource "azurerm_storage_account_static_website" "sa_web" {
  storage_account_id = azurerm_storage_account.sa.id
  index_document     = var.index_document
}

# resource "azurerm_resource_group" "rg_backend" {
#   name     = var.rg_backend_name
#   location = var.rg_backend_location
# }

# resource "azurerm_storage_account" "sa_backend" {
#   name                     = "${lower(var.sa_backend_name)}${random_string.random_string.result}"
#   resource_group_name      = azurerm_resource_group.rg_backend.name
#   location                 = azurerm_resource_group.rg_backend.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }



# resource "azurerm_storage_container" "sc_backend" {
#   name                  = var.sc_backend_name
#   storage_account_id    = azurerm_storage_account.sa_backend.id
#   container_access_type = "private"
# }

# resource "azurerm_key_vault" "kv_backend" {
#   name                        = "${lower(var.kv_backend_name)}${random_string.random_string.result}"
#   location                    = azurerm_resource_group.rg_backend.location
#   resource_group_name         = azurerm_resource_group.rg_backend.name
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Get", "List", "Create", "Delete",
#     ]

#     secret_permissions = [
#       "Get", "Set", "List", "Delete",
#     ]

#     storage_permissions = [
#       "Get", "Set", "List", "Delete",
#     ]
#   }
# }

# resource "azurerm_key_vault_secret" "sa_backend_accesskey" {
#   name         = var.sa_backend_accesskey_name
#   value        = azurerm_storage_account.sa_backend.primary_access_key
#   key_vault_id = azurerm_key_vault.kv_backend.id
# }
