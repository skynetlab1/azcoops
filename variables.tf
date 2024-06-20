variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
  default     = "westeurope"
}

variable "resource_group" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default     = "azcoops"
}
variable "admin_username" {
  description = "The admin username for the VM."
  type        = string
  default     = "adminuser"
}


variable "public_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "vm_user" {
  type    = string
  default = "adminuser"
}