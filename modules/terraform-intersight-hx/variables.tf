### HyperFlex Profile Variables

variable "action" {
  type = string
  default = "Validate" # Validate, Deploy, Continue, Retry, Abort, Unassign

  validation {
    condition = contains(["Validate", "Deploy", "Continue", "Retry", "Abort", "Unassign"], var.action)
    error_message = "The action value must be one of Validate, Deploy, Continue, Retry, Abort or Unassign."
  }
}

variable "wait_for_completion" {
  type = bool
  default = false
}

variable "tags" {
  type    = list(map(string))
  default = []
}

variable "organization" {
  type        = string
  description = "Organization Name"
  default     = "default"
}

variable "cluster" {
  type = object({
    name                          = string
    description                   = string
    data_ip_address               = string
    hypervisor_control_ip_address = string
    hypervisor_type               = string ## ESXi, IWE, HyperV
    mac_address_prefix            = string
    mgmt_ip_address               = string
    mgmt_platform                 = string ## EDGE, FI
    replication                   = number
    host_name_prefix              = string
    storage_data_vlan             = object({
      name    = string
      vlan_id = number
      })
    storage_cluster_auxiliary_ip  = optional(string)
    storage_type                  = optional(string)
    wwxn_prefix                   = optional(string)
    ## IWE ONLY ##
    storage_client_vlan = object({
      name       = string
      vlan_id    = number
      ip_address = string
      netmask    = string
      })
    cluster_internal_subnet       = optional(object({
      gateway                     = string
      ip_address                  = string
      netmask                     = string
      }))
    })
}

variable "local_cred_policy" {
  type = object({
    use_existing                = bool
    name                        = string
    factory_hypervisor_password = optional(bool)
    hxdp_root_pwd               = optional(string)
    hypervisor_admin            = optional(string) # admin
    hypervisor_admin_pwd        = optional(string)
  })
}

variable "sys_config_policy" {
  type = object({
    use_existing    = bool
    name            = string
    description     = optional(string)
    dns_domain_name = optional(string)
    dns_servers     = optional(list(string))
    ntp_servers     = optional(list(string))
    timezone        = optional(string)
  })
}

variable "vcenter_config_policy" {
  type = object({
    use_existing  = bool
    name          = string
    description   = optional(string)
    data_center   = optional(string)
    hostname      = optional(string)
    password      = optional(string)
    sso_url       = optional(string)
    username      = optional(string)
  })
  default = null
}

variable "cluster_storage_policy" {
  type = object({
    use_existing                    = bool
    name                            = string
    description                     = optional(string)
    disk_partition_cleanup          = optional(bool)
    vdi_optimization                = optional(bool)
    logical_avalability_zone_config = object({
      auto_config = optional(bool)
      })
  })
  default = null
}

variable "auto_support_policy" {
  type = object({
    use_existing              = bool
    name                      = string
    description               = optional(string)
    admin_state               = optional(bool)
    service_ticket_receipient = optional(string)
  })
  default = null
}

variable "node_config_policy" {
  type = object({
    use_existing     = bool
    name             = string
    description      = optional(string)
    node_name_prefix = optional(string)
    data_ip_range = object({
      end_addr    = optional(string)
      gateway     = optional(string)
      netmask     = optional(string)
      start_addr  = optional(string)
      })
    hxdp_ip_range = object({
      end_addr    = optional(string)
      gateway     = optional(string)
      netmask     = optional(string)
      start_addr  = optional(string)
      })
    hypervisor_control_ip_range = object({
      end_addr    = optional(string)
      gateway     = optional(string)
      netmask     = optional(string)
      start_addr  = optional(string)
      })
    mgmt_ip_range = object({
      end_addr    = optional(string)
      gateway     = optional(string)
      netmask     = optional(string)
      start_addr  = optional(string)
      })
  })
}

variable "cluster_network_policy" {
  type = object({
    use_existing = bool
    name         = string
    description  = optional(string)
    jumbo_frame  = optional(bool)
    mac_prefix_range = object({
      end_addr   = optional(string)
      start_addr = optional(string)
      })
    mgmt_vlan = object({
      name    = optional(string)
      vlan_id = optional(number)
      })
    uplink_speed = optional(string)
    vm_migration_vlan = object({
      name    = optional(string)
      vlan_id = optional(number)
      })
    vm_network_vlans = list(object({
      name    = optional(string)
      vlan_id = optional(number)
      }))
  })
}

variable "proxy_setting_policy" {
  type = object({
    use_existing  = bool
    name          = string
    description   = optional(string)
    hostname      = optional(string)
    password      = optional(string)
    port          = optional(number)
    username      = optional(string)
  })
  default = null
}

variable "ext_fc_storage_policy" {
  type = object({
    use_existing = bool
    name         = string
    description = optional(string)
    admin_state = optional(bool)
    exta_traffic = object({
      name    = optional(string)
      vsan_id = optional(number)
      })
    extb_traffic = object({
      name    = optional(string)
      vsan_id = optional(number)
      })
    wwxn_prefix_range = object({
      end_addr   = optional(string)
      start_addr = optional(string)
      })
  })
  default = null
}

variable "ext_iscsi_storage_policy" {
  type = object({
    use_existing = bool
    name         = string
    description = optional(string)
    admin_state = optional(bool)
    exta_traffic = object({
      name    = optional(string)
      vlan_id = optional(number)
      })
    extb_traffic = object({
      name    = optional(string)
      vlan_id = optional(number)
      })
  })
  default = null
}

variable "software_version_policy" {
  type = object({
    use_existing            = bool
    name                    = string
    description             = optional(string)
    server_firmware_version = optional(string)
    hypervisor_version      = optional(string)
    hxdp_version            = optional(string)
  })
}

variable "ucsm_config_policy" {
  type = object({
    use_existing  = bool
    name          = string
    description   = optional(string)
    kvm_ip_range = object({
      end_addr    = optional(string)
      gateway     = optional(string)
      netmask     = optional(string)
      start_addr  = optional(string)
      })
    server_firmware_version = optional(string)
  })
  default = null
}
