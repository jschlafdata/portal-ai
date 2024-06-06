# Terraform Databricks/Azure Providers

* .env file is loaded using steps described in TFVARS generation script.

![Providers Used](/img/az-db-providers.png)


```hcl title="providers.tf"
# Define Azure AD provider
provider "azuread" {
  alias = "azure_cli"
}

# Define Azure provider
provider "azurerm" {
  alias  = "azure_cli"
  features {}
}

# Define Azure AD provider
provider "azuread" {
  alias           = "azuread_sp"
  client_id       = module.azure-databricks-application.azure_client_id
  client_secret   = module.azure-databricks-application.azure_client_secret
  tenant_id       = module.azure-databricks-application.tenant_id
}


# Define Azure provider
provider "azurerm" {
  alias           = "azurerm_sp"
  client_id       = module.azure-databricks-application.azure_client_id
  client_secret   = module.azure-databricks-application.azure_client_secret
  tenant_id       = module.azure-databricks-application.tenant_id
  subscription_id = var.aad_subscription_id
  features {}
}


provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}


# Define the Databricks Workspace provider
provider "databricks" {
  alias               = "databricks_az_wks_dev"
  host                = module.adb-lakehouse["dev"].workspace_url
  azure_client_id     = module.azure-databricks-application.azure_client_id
  azure_tenant_id     = module.azure-databricks-application.tenant_id
  azure_client_secret = module.azure-databricks-application.azure_client_secret
}
```
