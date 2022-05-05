variable "azure_region" {
  type = string
  default = "South India"
  description = "Location for Azure Deployments"
}

variable "azure_vpc_range" {
  default = "10.2.0.0/16"
  description = "IP Range for VPC"
}

variable "azure_subnet1_range" {
  default = "10.2.1.0/24"
  description = "IP Range for Subnet1"
}

variable "azure_subnet2_range" {
  default = "10.2.2.0/24"
  description = "IP Range for Subnet1"
}

variable "mysql_admin_username" {
  default = "shivam"
}

variable "mysql_admin_password" {
  default = "ShiVVaMm-#-@@@@2102"
}