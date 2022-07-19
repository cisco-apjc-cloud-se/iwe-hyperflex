### COMMON SETTINGS ###
action              = "Unassign" # Validate, Deploy, Continue, Retry, Abort, Unassign, No-op
wait_for_completion = false
organization        = "default"
tags                = []

### HYPERFLEX CLUSTER SETTINGS ###
cluster = {
  name                          = "TF-HX-IWE"
  description                   = "HX Cluster deployed by Terrafrom"
  data_ip_address               = "169.254.0.1" # 169.254.0.1
  hypervisor_control_ip_address = "172.31.255.2"
  hypervisor_type               = "IWE" # ESXi, IWE
  mac_address_prefix            = "00:25:B5:00"
  mgmt_ip_address               = "10.67.53.226"
  mgmt_platform                 = "FI" # FI, EDGE
  replication                   = 3
  host_name_prefix              = "tf-hx-iwe" # Must be lowercase
  # storage_cluster_auxiliary_ip  = ""
  # storage_type                  = "HyperFlexDp" # HyperFlexDp, ThirdParty
  # wwxn_prefix                   = ""

  storage_data_vlan = {
    name    = "HX-STR-DATA-103"
    vlan_id = 103
    }

  # ### IWE HYPERVISOR ONLY ###
  storage_client_vlan = {
    name        = "HX-STR-CLIENT-104"
    vlan_id     = 104
    ip_address  = "169.254.240.1"
    netmask     = "255.255.248.0" # 255.255.248.0 hard set!
    }

  cluster_internal_subnet = {
    gateway                     = "192.168.0.1"
    ip_address                  = "192.168.0.0"
    netmask                     = "255.255.0.0"
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
  use_existing  = true
  name          = "mel-dc4-hx1-local-credential-policy"
}

sys_config_policy = {
  use_existing  = true
  name          = "mel-dc4-hx1-sys-config-policy"
}

# vcenter_config_policy = {
#   use_existing  = true
#   name          = "mel-dc4-hx1-vcenter-config-policy"
# }

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
  name              = "tf-hx-iwe-cluster-node-config-policy"
  description       = "HX IWE Cluster Network Policy built from Terraform"
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
  ### (IWE ONLY) HYPERVISOR CLUSTER CONTROL NETWORK IPs ###
  hypervisor_control_ip_range = {
    start_addr  = "172.31.255.10"
    end_addr    = "172.31.255.255"
    gateway     = "172.31.255.1"
    netmask     = "255.255.255.0"
    }

}

cluster_network_policy = {
  use_existing        = false
  name                = "tf-hx-iwe-cluster-network-policy"
  description         = "HX IWE Cluster Network Policy built from Terraform"
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
    name    = "IWE-HYPER-NET-105"
    vlan_id = 105
  }
  ### NOTE: Cluster Network Policy is locked after deployment.
  ### These VM Network VLANs are provisioned during initial deployment. Preference is to add these post-deployment
  ### For Day 2 VLAN changes see "additional_vm_network_vlans".

  vm_network_vlans    = [
    # {
    #   name    = "IWE-VM-NET-106"
    #   vlan_id = 106
    # }
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
  name                    = "tf-iwe-sw-version"
  description             = "HX IWE cluster software version policy created by Terraform"
  server_firmware_version = "4.2(1i)"
  hypervisor_version      = "1.2(1a)"
  hxdp_version            = "4.5(2b)"
}

# ucsm_config_policy = {
#   use_existing = true
#   name = ""
# }

### Additional (Day 2) VM Network VLANs ###
## NOTE:
## - name must be lower case - sub-module will convert to lower.
## -

additional_vm_network_vlans = [
  # {
  #   name    = "LAB-29"
  #   vlan_id = 29
  #   description = "Day 2 VLAN created by Terraform"
  #   vswitch = "vm"
  #   mtu = 1500
  #   network_type = "L2"
  # },
  {
    name    = "test-108"
    vlan_id = 108
    description = "Day 2 VLAN created by Terraform"
    # vswitch = "vm"
    # mtu = 1500
    # network_type = "L2"
  }
]
