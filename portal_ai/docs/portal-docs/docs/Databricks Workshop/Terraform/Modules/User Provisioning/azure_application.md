# Azure Application Module Documentation

This module is responsible for creating an Azure Active Directory (Azure AD) application and its associated service principal, which are used by Terraform to manage Azure resources. It also includes the generation of a secret for the service principal and assigns the service principal to the Owner role within the Azure subscription.

## Resources

### Azure Active Directory Application

- **Resource**: `azuread_application.this`
- **Purpose**: Creates an Azure AD application. The application's display name is constructed from the provided prefix and the specified service principal display name.
- **Key Attributes**:
  - `display_name`: Constructed from `${var.prefix}-${var.azure_service_principal_display_name}`.

### Azure Active Directory Service Principal

- **Resource**: `azuread_service_principal.this`
- **Purpose**: Creates a service principal for the Azure AD application. This service principal is used for authentication and authorization in Azure.
- **Key Attributes**:
  - `client_id`: The client ID of the Azure AD application.

### Service Principal Password

- **Resource**: `azuread_service_principal_password.this`
- **Purpose**: Generates a password for the Azure AD service principal. The password is rotated every 30 days.
- **Key Attributes**:
  - `service_principal_id`: The object ID of the service principal.
  - `rotate_when_changed`: Triggers rotation based on the `time_rotating.month.id`.

### Role Assignment to Subscription

- **Resource**: `azurerm_role_assignment.core`
- **Purpose**: Assigns the service principal to the Owner role within the specified Azure subscription. This grants the service principal full access to manage the subscription's resources.
- **Key Attributes**:
  - `scope`: The ID of the Azure subscription.
  - `role_definition_name`: Specifies the role of "Owner".
  - `principal_id`: The object ID of the service principal.

## Outputs

- **`azure_client_id`**: Outputs the Azure AD service principal's application (client) ID.
- **`azure_client_secret`**: Outputs the Azure AD service principal's client secret value.
- **`tenant_id`**: Outputs the tenant ID of the current Azure AD tenant.
- **`azure_service_principal_display_name`**: Outputs the display name of the Azure AD application.

## Variables

- **`azure_service_principal_display_name`**: A display name for the Azure AD service principal. This is a required input.
- **`aad_subscription_id`**: The ID of the Azure subscription. This is a required input.
- **`prefix`**: A prefix used to construct resource names, contributing to uniqueness and identification. This is a required input.
