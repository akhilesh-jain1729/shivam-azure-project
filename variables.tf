variable "subscription_id" {
  type = string
  default  = "ec811817-c2d8-43e4-9334-78b9e9f053c5"
  description = "Subscription ID in my Azure"
}
  
variable "tenant_id"  {
  type = string
  default  = "b52e9fda-0691-4585-bdfc-5ccae1ce1890"
  description = "Tenant ID/Directory ID in my Azure"
}  

variable "client_id" {
  type = string
  default   = ""
  description = "Client ID in my Azure"
}
      
variable "client_secret" {
  type = string
  default = ""
  description = "Client Secret in my Azure"
}