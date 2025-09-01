rg_name  = "test-rg1"
location = "East US"

vnet = [
  { name = "hub-vnet", address_space = "10.0.0.0/16" },
  { name = "spoke1-vnet", address_space = "20.0.0.0/16" },
  { name = "spoke2-vnet", address_space = "30.0.0.0/16" },
  { name = "spoke3-vnet", address_space = "40.0.0.0/16" }
]

subnet = [

  { name = "spoke1-vnet", subnet_name = "spoke1-subnet", address_prefix = "20.0.0.0/24" },
  { name = "spoke2-vnet", subnet_name = "spoke2-subnet", address_prefix = "30.0.0.0/24" },
  { name = "hub-vnet", subnet_name = "AzureFirewallSubnet", address_prefix = "10.0.0.0/24" }

]