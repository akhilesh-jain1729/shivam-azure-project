module "azure" {
  source = "./azure_module" 
  providers = {
    azurerm = azurerm.myazure
  }   
}