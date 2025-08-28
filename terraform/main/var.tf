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