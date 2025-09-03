variable "location" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}



variable "vnet" {
  type = list(object(
    {
      name          = string
      address_space = string
    }
  ))
}

variable "subnet" {
  type = list(object(
    {
      subnet_name    = string
      address_prefix = string
      name           = string
    }
  ))
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}
