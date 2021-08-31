variable "prefix" {
  description = "Prefix for all the resources"
  default     = "servian"
}

variable "location" {
  description = "location of all the resources"
  default     = "australiaeast"
}

variable "username" {
  description = "username of the vm"
  default     = "localadmin"
}


variable "vnet_interface" {
  description = "CIDR range of the VNET"
  default     = ["10.0.0.0/24"]
}

variable "address_prefixes" {
  description = "CIDR range of the subnet in the VNET"
  default     = ["10.0.0.0/26"]
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_DS1_v2"
}

variable "nsg_rule" {
  description = "ingress nsg rules for multiple ports"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "allow_ssh"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow_http"
      priority                   = 1100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow_https"
      priority                   = 1110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow_custom"
      priority                   = 1200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "key_vault" {
  description = "base key vault name"
  default     = "KV-BASE-31741"
}

variable "secret_name" {
  description = "key vault secret name"
  default     = "password1"
}

variable "base_rg" {
  description = "base rg name"
  default     = "RG_BASE"
}

variable "default_tags" {
  type = map(string)
  default = {
    CreatedBy : "Rohit",
    CreatedFor : "servian"
  }
}