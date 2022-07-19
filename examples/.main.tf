terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "iwe-hyperflex"
    }
  }
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      # version = "1.0.12"
    }
  }
}

### COMMON PROVIDERS ###
provider "intersight" {
  # Configuration options
  apikey    = var.intersight_key
  secretkey = var.intersight_secret
  endpoint =  var.intersight_url
}

### HYPERFLEX CLUSTER PROVISIONING MODULE ###
module "hx" {
  source = "./modules/terraform-intersight-hx"

  action              = var.action
  wait_for_completion = var.wait_for_completion
  organization        = var.organization
  tags                = var.tags

  cluster                         = var.cluster
  nodes                           = var.nodes
  local_cred_policy               = var.local_cred_policy
  sys_config_policy               = var.sys_config_policy
  vcenter_config_policy           = var.vcenter_config_policy
  # cluster_storage_policy = {}
  auto_support_policy             = var.auto_support_policy
  node_config_policy              = var.node_config_policy
  cluster_network_policy          = var.cluster_network_policy
  # proxy_setting_policy = {}
  # ext_fc_storage_policy = {}
  # ext_iscsi_storage_policy = {}
  software_version_policy         = var.software_version_policy
  # ucsm_config_policy = {}

  ### Additional (Day 2) VLANs for IWE Cluster ###
  cluster_deployed                = false # Set to true after cluster deployed to configure day 2 vlans
  additional_vm_network_vlans     = var.additional_vm_network_vlans

}
