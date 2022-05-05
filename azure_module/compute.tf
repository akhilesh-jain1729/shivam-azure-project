resource "azurerm_resource_group" "myrg" {
  name     = "myproject_rg"
  location = var.azure_region
}

resource "azurerm_network_security_group" "sg" {
  name                = "security"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  security_rule = []
  tags = {
    Name = "security_wizard"
  }
}

resource "azurerm_network_security_rule" "sgrule1" {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sgrule2" {
    name                       = "allow-http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sgrule3" {
    name                       = "k8s-1"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "6443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sgrule4" {
    name                       = "k8s-2"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "8080"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sgrule5" {
    name                       = "ping"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sgrule7" {
    name                       = "egress"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.myrg.name
    network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_mysql_server" "mysql-server" {
  name                = "mysqlserver-for-wordpress"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = "Central India"

  administrator_login          = var.mysql_admin_username
  administrator_login_password = var.mysql_admin_password

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mysql_database" "mysql-db" {
  name                = "wordpress-db"
  resource_group_name = azurerm_resource_group.myrg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "mysql-fw-rule" {
  name                = "My-system-ip"
  resource_group_name = azurerm_resource_group.myrg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  start_ip_address    = "42.109.212.58"
  end_ip_address      = "42.109.212.60"
}

resource "azurerm_log_analytics_workspace" "monitor1" {
  name                = "monitor1-law"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "monitor2" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.monitor1.id
  workspace_name        = azurerm_log_analytics_workspace.monitor1.name
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_kubernetes_cluster" "myaks" {
  name                = "my-aks"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  dns_prefix          = "shivamaks1"
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
    vnet_subnet_id = element(azurerm_virtual_network.vpc.subnet[*].id,0)
    enable_node_public_ip = true
    type                = "VirtualMachineScaleSets"
  }
  identity {
    type = "SystemAssigned"
  }
    network_profile {
      network_plugin     = "kubenet"
      service_cidr       = "10.0.0.0/16"
      dns_service_ip     = "10.0.0.10"
      docker_bridge_cidr = "172.17.0.1/24"
       load_balancer_sku = "standard"
  }
  tags = {
    Environment = "Production"
  }
   oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor1.id
  }
}