# Databricks Workspace Creation Module Documentation

This module provisions Azure resources necessary for setting up a Databricks workspace, including data factories, key vaults, virtual networks, subnets, and the workspace itself. It is designed to be flexible, allowing for optional resource creation based on provided configurations.

## Resources

### Azure Data Factory

- **Resource**: `azurerm_data_factory.adf`
- **Condition**: Created if a name for the data factory is provided.
- **Purpose**: Provisions an Azure Data Factory instance for data integration and transformation processes.
- **Key Attributes**:
  - `name`: The name of the data factory.
  - `location`: Azure region where the data factory is deployed.
  - `resource_group_name`: The resource group containing the data factory.
  - `tags`: Metadata tags assigned to the data factory.

### Azure Key Vault

- **Resource**: `azurerm_key_vault.example`
- **Condition**: Created if a name for the key vault is provided.
- **Purpose**: Sets up an Azure Key Vault for managing secrets, keys, and certificates.
- **Key Attributes**:
  - `name`: The name of the key vault.
  - `location`: Azure region where the key vault is deployed.
  - `resource_group_name`: The resource group containing the key vault.
  - `enabled_for_disk_encryption`: Enables the key vault for disk encryption.
  - `tenant_id`: The Azure AD tenant ID associated with the key vault.
  - `sku_name`: Specifies the pricing tier of the key vault.

### Azure Resource Group

- **Resource**: `azurerm_resource_group.this`
- **Condition**: Created if the flag to create a new resource group is true.
- **Purpose**: Initializes a new resource group for hosting the Databricks workspace and related resources.
- **Key Attributes**:
  - `name`: The name of the resource group.
  - `location`: Azure region where the resource group is created.
  - `tags`: Metadata tags assigned to the resource group.

### Azure Virtual Network

- **Resource**: `azurerm_virtual_network.this`
- **Purpose**: Creates a virtual network for the Databricks workspace and its resources.
- **Key Attributes**:
  - `name`: The name of the virtual network.
  - `location`: Azure region where the virtual network is deployed.
  - `resource_group_name`: The resource group containing the virtual network.
  - `address_space`: The IP address range allocated to the virtual network.

### Azure Network Security Group

- **Resource**: `azurerm_network_security_group.this`
- **Purpose**: Establishes a network security group for controlling access to network resources.
- **Key Attributes**:
  - `name`: The name of the network security group.
  - `location`: Azure region where the network security group is deployed.
  - `resource_group_name`: The resource group containing the network security group.

### Azure Subnets

- **Resources**: `azurerm_subnet.private` and `azurerm_subnet.public`
- **Purpose**: Configures private and public subnets within the virtual network for Databricks workspaces.
- **Key Attributes**:
  - `name`: The name of the subnet.
  - `resource_group_name`: The resource group containing the subnet.
  - `virtual_network_name`: The virtual network containing the subnet.
  - `address_prefixes`: The IP address range allocated to the subnet.

### Azure Databricks Workspace

- **Resource**: `azurerm_databricks_workspace.this`
- **Purpose**: Deploys an Azure Databricks workspace within the configured virtual network and subnets.
- **Key Attributes**:
  - `name`: The name of the Databricks workspace.
  - `resource_group_name`: The resource group containing the Databricks workspace.
  - `managed_resource_group_name`: The name of the resource group managed by Databricks for workspace resources.
  - `location`: Azure region where the Databricks workspace is deployed.
  - `sku`: The pricing tier of the Databricks workspace, e.g., "premium".
  - `custom_parameters`: Configuration parameters for network and security settings.

## Considerations

This module leverages local values and conditional resource creation to adapt to various deployment needs. It ensures that necessary networking and security configurations are in place for a secure and efficient Databricks environment.
