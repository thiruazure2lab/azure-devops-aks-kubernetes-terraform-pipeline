resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}"
  location            = azurerm_resource_group.aks_rg.location
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  resource_group_name = azurerm_resource_group.aks_rg.name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"
  
  # Add On Profiles
  role_based_access_control_enabled = true
  http_application_routing_enabled =  true
  azure_policy_enabled = true
  cost_analysis_enabled = true
  sku_tier = "Standard"
  
  
  # Add On Profiles
  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [azuread_group.aks_administrators.object_id]
    #admin_group_object_ids = "1def9162-cd0e-4bd4-b618-c06c151a1c3b"
      }
  oms_agent {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
    }
# Identity (System Assigned or Service Principal)
  identity { type = "SystemAssigned" }


  default_node_pool {
      name       = "systempool"
      vm_size    = "Standard_DS2_v2"
      orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
      enable_auto_scaling  = true
      max_count            = 3
      min_count            = 1
      os_disk_size_gb      = 30
      type           = "VirtualMachineScaleSets"
      temporary_name_for_rotation = thiru
      node_labels = {
        "nodepool-type" = "system"
        "environment"   = var.environment
        "nodepoolos"    = "linux"
        "app"           = "system-apps"
      }
      tags = {
        "nodepool-type" = "system"
        "environment"   = var.environment
        "nodepoolos"    = "linux"
        "app"           = "system-apps"
      }    
    }

# Windows Admin Profile
windows_profile {
  admin_username            = var.windows_admin_username
  admin_password            = var.windows_admin_password
}

# Linux Profile
linux_profile {
  admin_username = "ubuntu"
  ssh_key {
      key_data = file(var.ssh_public_key)
  }
}

# Network Profile
network_profile {
  load_balancer_sku = "standard"
  network_plugin = "azure"
}

# AKS Cluster Tags 
tags = {
  Environment = var.environment
}



}
