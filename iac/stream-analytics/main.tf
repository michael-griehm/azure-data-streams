terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

variable "app_name" {
  default   = "asa"
  type      = string
  sensitive = false
}

variable "env" {
  default   = "demo"
  sensitive = false
}

variable "location" {
  default   = "East US 2"
  sensitive = false
}

variable "tags" {
  type = map(string)

  default = {
    environment = "demo"
    workload    = "crypto-analytics"
  }
}

variable "alert-function-name" {
  type      = string
  sensitive = true
}

variable "alert-function-access-key" {
  type      = string
  sensitive = true
}

locals {
  loc            = lower(replace(var.location, " ", ""))
  a_name         = replace(var.app_name, "-", "")
  fqrn           = "${var.app_name}-${var.env}-${local.loc}"
  fqrn_no_dashes = "${local.a_name}-${var.env}-${local.loc}"
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = local.fqrn
}