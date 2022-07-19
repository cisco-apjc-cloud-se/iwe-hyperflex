### COMMON SETTINGS ###
action              = "Deploy" # Validate, Deploy, Continue, Retry, Abort, Unassign, No-op
wait_for_completion = true
organization        = "default"
tags                = []

### HYPERFLEX CLUSTER SETTINGS ###
cluster = {
  name                          = "TF-HX-VSPHERE"
  description                   = "HX Cluster deployed by Terrafrom"
  data_ip_address               = "169.254.0.1" # 169.254.0.1
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

## NOTE: local_cred_policy defined in TFCB workspace variable
# local_cred_policy = {
#   use_existing  = false
#   name          = "tf-hx-vsphere-security-policy"
#   # hxdp_root_pwd               = "" TFCB Workspace Variable
#   hypervisor_admin            = "root"
#   # hypervisor_admin_pwd        = "" TFCB Workspace Variable
#   factory_hypervisor_password = true
# }

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
  ### HYPERFLEX STORAGE DATA NETWORK IPs ###
  # NOTE: Intersight will automatically allocate 169.254.0.0/24 for this network
  # data_ip_range = {
  #   start_addr  = ""
  #   end_addr    = ""
  #   gateway     = ""
  #   netmask     = ""
  #   }
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

  ### Needs at least one VM Network ###
  vm_network_vlans    = [
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
