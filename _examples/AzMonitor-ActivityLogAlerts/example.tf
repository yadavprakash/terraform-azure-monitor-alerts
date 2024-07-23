provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/yadavprakash/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "app"
  environment = "tested"
  location    = "North Europe"
}

module "azmonitor-action-group" {
  source      = "./../../"
  name        = "app"
  environment = "test"

  actionGroups = {
    "group1" = {
      actionGroupName      = "Notification"
      actionGroupShortName = "alertesc"
      actionGroupRGName    = module.resource_group.resource_group_name
      actionGroupEnabled   = "true"
      actionGroupEmailReceiver = [
        {
          name                    = "test"
          email_address           = "lxxx@gmail.com"
          use_common_alert_schema = "false"
        }
      ]
    }
  }
}

data "azurerm_monitor_action_group" "example" {
  depends_on          = [module.azmonitor-action-group]
  resource_group_name = module.resource_group.resource_group_name
  name                = "Notification"
}

#data "azurerm_network_security_group" "example" {
#  depends_on          = [module.resource_group]
#  name                = "example"
#  resource_group_name = module.resource_group.resource_group_name
#}



module "alerts" {
  depends_on  = [data.azurerm_monitor_action_group.example, ]
  source      = "./../../"
  name        = "app"
  environment = "test"
  activity_log_alert = {
    "test1" = {
      alertname      = "vm-restart"
      alertrg        = module.resource_group.resource_group_name
      alertscopes    = [module.resource_group.resource_group_id]
      description    = "Administrative alerts for vm"
      operation_name = "Microsoft.Compute/virtualMachines/restart/action"
      actionGroupID  = data.azurerm_monitor_action_group.example.id
      category       = "Administrative"
    },
    "test2" = {
      alertname      = "vm-powerOff"
      alertrg        = module.resource_group.resource_group_name
      alertscopes    = [module.resource_group.resource_group_id]
      description    = "Administrative alerts for vm"
      operation_name = "Microsoft.Compute/virtualMachines/powerOff/action"
      actionGroupID  = data.azurerm_monitor_action_group.example.id
      category       = "Administrative"
    }
  }
}
