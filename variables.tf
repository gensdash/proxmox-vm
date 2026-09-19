variable "content_type" {
	type        = string
	description = "Proxmox content type for the cloud-init user-data file."
	default     = "snippets"
}

variable "datastore_id" {
	type        = string
	description = "Datastore where the cloud-init user-data file is stored."
}

variable "node_name" {
	type        = string
	description = "Proxmox node that hosts the VM and cloud-init user-data file."
}

variable "file_mode" {
	type        = string
	description = "Permissions applied to the cloud-init user-data file."
	default     = "0700"
}

variable "vm_name" {
	type        = string
	description = "Name of the virtual machine."
}

variable "description" {
	type        = string
	description = "Description assigned to the virtual machine."
	default     = ""
}

variable "tags" {
	type        = set(string)
	description = "Tags assigned to the virtual machine."
	default     = []
}

variable "stop_on_destroy" {
	type        = bool
	description = "Whether to stop the VM before destroying it."
	default     = true
}

variable "operating_system_type" {
	type        = string
	description = "Proxmox operating system type for the VM."
	default     = "l26"
}

variable "agent_enabled" {
	type        = bool
	description = "Whether the QEMU guest agent is enabled for the VM."
	default     = true
}

variable "cpu_cores" {
	type        = number
	description = "Number of CPU cores assigned to the VM."
	default     = 2
}

variable "cpu_type" {
	type        = string
	description = "CPU type exposed to the VM."
	default     = "host"
}

variable "memory_dedicated" {
	type        = number
	description = "Amount of dedicated memory assigned to the VM in MiB."
	default     = 2048
}

variable "initialization" {
  type        = any
  description = "Initialization configuration for the VM."
  default     = {}
}

variable "network" {
  type        = any
  description = "Network configuration for the VM."
  default     = {}
}

variable "ip_address" {
  type        = string
  description = "IPv4 address assigned to the VM."
}

variable "netmask" {
  type        = string
  description = "Netmask for the VM's IPv4 address."
}

variable "gateway" {
  type        = string
  description = "Gateway for the VM's IPv4 address."
}

variable "dns_servers" {
  type      = list(string)
  description = "DNS servers for the VM."
}

variable "network_device_model" {
  type        = string
  description = "Model of the network device for the VM."
  default     = "virtio"
}

variable "network_device_bridge" {
  type        = string
  description = "Bridge for the network device of the VM."
  default     = "vmbr0"
}

variable "hostname" {
  type = string
}

variable "username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_authorized_keys" {
  type      = list(string)
  sensitive = false
}

variable "timezone" {
  type    = string
  default = "America/Mexico_City"
}

variable "packages" {
  type    = list(string)
  default = ["qemu-guest-agent", "net-tools"]
}