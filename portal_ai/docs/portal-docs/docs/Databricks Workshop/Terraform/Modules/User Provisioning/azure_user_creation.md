# Azure User Provisioning Module Documentation

This module handles the provisioning of users in Azure Active Directory (Azure AD) and their assignment to groups and roles for accessing Azure resources, specifically for Databricks workspaces.

## Resources

### Azure Active Directory User Invitation

- **Resource**: `azuread_invitation.example`
- **Purpose**: Invites users to join the Azure AD tenant using their email addresses. Each invited user receives an email with a link to join the tenant and access Azure Databricks workspaces.
- **Key Attributes**:
  - `user_email_address`: The email address of the invited user.
  - `user_display_name`: The display name of the invited user, derived from the local part of their email address.
  - `redirect_url`: The URL to which users are redirected after accepting the invitation, typically the Azure portal.
  - `message.body`: Customizable message body for the invitation email.

### Azure Active Directory Users Data Source

- **Data Source**: `azuread_users.users`
- **Purpose**: Retrieves a list of all users within the Azure AD tenant.
- **Key Attributes**:
  - `return_all`: Flag to return all users in the tenant.

### Local Variables for User Filtering

- **`excluded_user_names`**: A list of user display names to exclude from group membership and role assignments.
- **`included_users_ids`**: The object IDs of users to include, based on the exclusion list.
- **`included_users_emails`**: The email addresses of included users, used for outputs.

### Azure Active Directory Group

- **Resource**: `azuread_group.example`
- **Purpose**: Creates a user group in Azure AD for managing access to resources. This group includes users filtered by the exclusion list.
- **Key Attributes**:
  - `display_name`: The name of the group.
  - `owners`: The object ID of the current Azure AD client as the owner of the group.
  - `security_enabled`: Flag to enable security features for the group.
  - `members`: The object IDs of included users as members of the group.

### Azure Resource Manager Role Assignment

- **Resource**: `azurerm_role_assignment.databricks_rg_read_only`
- **Purpose**: Assigns the Reader role to the Azure AD group for specified Azure resource groups, granting read-only access to Databricks resources.
- **Key Attributes**:
  - `scope`: The Azure subscription and resource group to which the role is assigned.
  - `role_definition_name`: The name of the role, "Reader" in this case.
  - `principal_id`: The object ID of the Azure AD group.

## Outputs

- **`azuread_users`**: Outputs the email addresses of all included users.
  - **Description**: "All users in system as list."

## Variables

- **`aad_subscription_id`**: The ID of the Azure subscription.
- **`az_databricks_resource_groups`**: A list of Azure resource group names associated with Databricks workspaces.
- **`workspace_users_list`**: A list of user email addresses to be invited to Azure AD for accessing Databricks workspaces.
