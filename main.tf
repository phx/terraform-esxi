terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      #
      # For more information, see the provider source documentation:
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
    }
  }
}

variable "esxi_hostname" {
  description = "esxi hostname or ip address"
  type        = string
  default     = "esxi.local"
}

variable "esxi_ssh_port" {
  description = "esxi server ssh port"
  type        = string
  default     = "22"
}

variable "esxi_web_port" {
  description = "esxi server web port"
  type        = string
  default     = "443"
}

variable "esxi_username" {
  description = "esxi username"
  type        = string
  default     = "root"
}

variable "esxi_password" {
  description = "esxi password"
  type        = string
  default     = "password"
}

provider "esxi" {
  esxi_hostname      = "${var.esxi_hostname}"
  esxi_hostport      = "${var.esxi_ssh_port}"
  esxi_hostssl       = "${var.esxi_web_port}"
  esxi_username      = "${var.esxi_username}"
  esxi_password      = "${var.esxi_password}"
}

variable "guest_hostname" {
  description = "esxi guest hostname"
  type        = string
  default     = "vmtest"
}

variable "disk_store" {
  description = "esxi disk store where the guest will be created"
  type        = string
  default     = "MAIN_DATA_STORE_NAME"
}

variable "clone_from_vm" {
  description = "(optional) name of vm to create new vm from"
  type        = string
  default     = "VM_NAME_YOU_WANT_TO_CLONE_FROM"
}

variable "ovf_source" {
  description = "(optional) absolute path to .vmx or .ova file on local machine or url to .ova template"
  type        = string
  default     = "https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64.ova"
}

variable "virtual_network" {
  description = "name of default network interface"
  type        = string
  default     = "VM Network"
}

variable "storage" {
  description = "size of guest disk in GB"
  type        = number
  default     = 80
}

variable "storage_type" {
  description = "type of disk provisioning (thin, zeroedthick, or eagerzeroedthick)"
  type        = string
  default     = "thin"
}

variable "memory" {
  description = "size of guest memory in MB"
  type        = number
  default     = 2048
}

variable "cpus" {
  description = "number of virtual cpus"
  type        = number
  default     = 2
}


########## variables done -- start doing stuff:

resource "esxi_guest" "guest" {
  guest_name         = "${var.guest_hostname}"
  disk_store         = "${var.disk_store}"

  #
  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  clone_from_vm      = "${var.clone_from_vm}"
  #ovf_source         = "${var.ovf_source}"
  boot_disk_size     = "${var.storage}"
  boot_disk_type     = "${var.storage_type}"
  memsize            = "${var.memory}"
  numvcpus           = "${var.cpus}"
  power              = "on"
  network_interfaces {
    # static ip info: https://github.com/josenk/terraform-provider-esxi-wiki/blob/master/How%20to%20configure%20a%20static%20IP%20using%20remote-exec.md
    virtual_network = "${var.virtual_network}"
    nic_type        = "e1000e"
  }
  guest_startup_timeout  = 45
  guest_shutdown_timeout = 30
}

#ip_address - Computed - The IP address reported by VMware tools.
#boot_disk_type - Optional - Guest boot disk type. Default 'thin'. Available thin, zeroedthick, eagerzeroedthick.
#boot_disk_size - Optional - Specify boot disk size or grow cloned vm to this size.
#guestos - Optional - Default will be taken from cloned source.
#boot_firmware - Optional - If "efi", enable efi boot. - Default "bios" (BIOS boot)
#clone_from_vm - Source vm to clone. Mutually exclusive with ovf_source option.
#ovf_source - ovf files or URLs to use as a source. Mutually exclusive with clone_from_vm option.
#disk_store - Required - esxi Disk Store where guest vm will be created.
#resource_pool_name - Optional - Any existing or terraform managed resource pool name. - Default "/".
#memsize - Optional - Memory size in MB. (ie, 1024 == 1GB). See esxi documentation for limits. - Default 512 or default taken from cloned source.
#numvcpus - Optional - Number of virtual cpus. See esxi documentation for limits. - Default 1 or default taken from cloned source.
#virthwver - Optional - esxi guest virtual HW version. See esxi documentation for compatible values. - Default 8 or taken from cloned source.
#network_interfaces - Array of up to 10 network interfaces.
#virtual_network - Required for each Guest NIC - This is the esxi virtual network name configured on esxi host.
#power - Optional - on, off.
