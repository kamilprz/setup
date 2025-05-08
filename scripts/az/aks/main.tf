resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.prefix}-aks-dns"
  kubernetes_version  = "1.33"

  default_node_pool {
    name                = "agentpool"
    node_count          = 2
    vm_size             = "Standard_D4ds_v5"
    type                = "VirtualMachineScaleSets"
    node_labels         = var.labels
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.labels
}