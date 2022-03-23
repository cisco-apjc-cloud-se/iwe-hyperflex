# Intersight HyperFlex Cluster Terraform Module

## Introduction
This module will simplify the configuration & deployment of a HyperFlex HCI cluster through the Intersight Cloud Operating Platform.

HyperFlex clusters are configured using a set of policies grouped together as a profile.  The profile is then assigned to a group of physical HyperFlex servers, themselves either connected and managed through a pair of Cisco UCS Fabric Interconnects (i.e. **HyperFlex Data Center** clusters) or connected directly any upstream switches (i.e. **HyperFlex Edge** clusters).  This module will support either connectivity model.

This module will suport deploying HyperFlex clusters with either the default *VMware vSphere ESXi* operating system, or now the *[Cisco Intersight Workload Engine (IWE)](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/intersight/at-a-glance-c45-2470301.html)* operating system for Kubernetes workloads. There are some configuration differences between these two operating systems.  Please see the section for each OS below.

## Usage

### VMware vSphere ESXi Operating System

#### Assumptions
* Intersight credentials have been configured as either a local tfvars file excluded from the Git repository or as a sensitive variable in the Terraform workspace (Cloud / Enterprise verions).  These credentials should never be included in any Git code repositories.
* The passwords to use for HXDP and Hypervisor Admin (root) accounts should also be defined in either a local tfvars file excluded from the Git repository or as a sensitive variable in the Terraform workspace (Cloud / Enterprise verions).  These credentials should never be included in any Git code repositories.
* If required, a vCenter instance should be available for the HX cluster to be registered to.  This is defined in an associated, optional vCenter configuration policy.  If creating a new policy with Terraform, the password for the vCenter account should not be included in the code directly and instead be configured in either a local tfvars file excluded from the Git repository or as a sensitive variable in the Terraform workspace (Cloud / Enterprise verions).

#### Usage
The following is an example plan that uses this module to define and create a new VMware vSphere ESXi-based HyperFlex DC cluster assigned to 3 servers (nodes).  

```hcl
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

  ### COMMON SETTINGS ###
  action              = "Deploy" # Validate, Deploy, Continue, Retry, Abort, Unassign, No-op
  wait_for_completion = false
  organization        = "default"
  tags                = []

  ### HYPERFLEX CLUSTER SETTINGS ###
  cluster = {
    name                          = "TF-HX-VSPHERE"
    description                   = "HX Cluster deployed by Terrafrom"
    # data_ip_address               = "169.254.0.1"
    hypervisor_control_ip_address = "172.31.255.2"
    hypervisor_type               = "ESXi" # ESXi, IWE
    mac_address_prefix            = "00:25:B5:00"
    mgmt_ip_address               = "10.67.53.226"
    mgmt_platform                 = "FI" # FI, EDGE
    replication                   = 3
    host_name_prefix              = "tf-hx-svr" # Must be lowercase
    # storage_cluster_auxiliary_ip  = ""
    # storage_type                  = "HyperFlexDp" # HyperFlexDp, ThirdParty
    # wwxn_prefix                   = ""

    storage_data_vlan = {
      name    = "HX-STR-DATA-103"
      vlan_id = 103
      }

    }

  ### ASSIGNED NODES (SERVERS) ###
  nodes = {
    WZP23470VYT = {
      cluster_index           = 1
      ## NOTE: Intersight will dynamically allocate IPs from pools defined in node config policy if not set explicitly ##
      # hxdp_data_ip            = ""
      # hxdp_mgmt_ip            = ""
      # hypervisor_data_ip      = ""
      # hypervisor_mgmt_ip      = ""
      # ## IWE ONLY
      # hxdp_storage_client_ip  = ""
      # hypervisor_control_ip   = ""

    }
    WZP23470VYJ = {
      cluster_index = 2
    }
    WZP23470VYE = {
      cluster_index = 3
    }
  }

  ### ASSOCIATED POLICIES ###

  local_cred_policy = {
    ## NOTE: Passwords have been defined as TFCB workspace variables. No passwords stored here.
    use_existing  = false
    name          = "tf-hx-vsphere-security-policy"
    hxdp_root_pwd               = var.hxdp_root_pwd
    hypervisor_admin            = "root"
    hypervisor_admin_pwd        = var.hypervisor_admin_pwd
    factory_hypervisor_password = true
  }

  sys_config_policy = {
    use_existing  = true
    name          = "mel-dc4-hx1-sys-config-policy"
  }

  vcenter_config_policy = {
    use_existing  = true
    name          = "mel-dc4-hx1-vcenter-config-policy"
  }

  # cluster_storage_policy = {
  #   use_existing  = true
  #   name          = ""
  # }

  auto_support_policy = {
    use_existing  = true
    name          = "mel-dc4-hx1-auto-support-policy"
  }

  node_config_policy = {
    use_existing      = false
    name              = "tf-hx-vsphere-cluster-node-config-policy"
    description       = "HX vSphere ESXi Cluster Network Policy built from Terraform"
    ### HYPERVISOR MANAGMENT IPs ###
    mgmt_ip_range = {
      start_addr  = "10.67.53.227"
      end_addr    = "10.67.53.230"
      gateway     = "10.67.53.225"
      netmask     = "255.255.255.224"
    }
    ### HYPERFLEX STORAGE CONTROLLER MANAGMENT IPs ###
    hxdp_ip_range = {
      start_addr  = "10.67.53.231"
      end_addr    = "10.67.53.234"
      gateway     = "10.67.53.225"
      netmask     = "255.255.255.224"
      }
  }

  cluster_network_policy = {
    use_existing        = false
    name                = "tf-hx-vsphere-cluster-network-policy"
    description         = "HX vSphere ESXi Cluster Network Policy built from Terraform"
    jumbo_frame         = true
    uplink_speed        = "default"
    kvm_ip_range        = {
      start_addr  = "10.67.29.115"
      end_addr    = "10.67.29.118"
      netmask     = "255.255.255.0"
      gateway     = "10.67.29.1"
    }
    mgmt_vlan           = {
      name    = "IWE-MGMT-107"
      vlan_id = 107
    }
    vm_migration_vlan   = {
      name    = "LOCAL-VMOTION-102"
      vlan_id = 102
    }
    vm_network_vlans    = [
      ### NOTE: Cluster Network Policy requires at least one VM Network to be defined ###
      {
        name    = "HX-VM-NET-106"
        vlan_id = 106
      }
    ]
  }

  # proxy_setting_policy = {
  #   use_existing  = true
  #   name          = ""
  # }

  # ext_fc_storage_policy = {
  #   use_existing = true
  #   name = ""
  # }

  # ext_iscsi_storage_policy = {
  #   use_existing = true
  #   name = ""
  # }

  software_version_policy = {
    use_existing            = false
    name                    = "tf-vsphere-sw-version"
    description             = "HX vSphere ESXi cluster software version policy created by Terraform"
    server_firmware_version = "4.2(1i)"
    hxdp_version            = "4.5(2b)"
  }

  # ucsm_config_policy = {
  #   use_existing = true
  #   name = ""
  # }
}

```

### Cisco Intersight Workload Engine Operating System

## Caveats
* The Intersight Terraform provider tracks the `action` parameter as a stateful configuration parameter however Interisght will change this parameter to `No-op` after the action has been submitted.  This will mean any subsequent runs will show the `action` parameter as not matching the state and Terraform will attempt to redeploy the cluster.  This should have no impact however as Intersight will verify nothing has changed.  To avoid this being seen as a state change in Terraform, set the `action` parameter to `No-op`.

![tfcb plan no-op to deploy](./images/no-op-deploy.png)

![tfcb plan no-op to deploy intersight view](./images/no-op-deploy2.png)

* `wait_for_completion = true` and `action = deploy` will cause Terraform to wait until the deployment has completed.  For HX deployments, this may take longer than the default timeout of 2 hours so this combination is not recommended.  

![tfcb apply failed](./images/apply-failed.png)

* For IWE deployments, adding VM network VLANs requires the cluster to have been deployed first then the plan run and applied a 2nd time, but with the variable `cluster_deployed` set to `true`. Also the `action` parameter is not applicable to adding (or removing) additional VLANs.