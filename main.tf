resource "proxmox_virtual_environment_file" "user_data_cloud" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name = var.node_name

  file_mode = "0600"

  source_raw {
    file_name = "${var.vm_name}-user-data.yaml"

    data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
      hostname          = var.hostname
      username          = var.username
      ssh_authorized_keys = var.ssh_authorized_keys
      timezone           = var.timezone
      packages          = var.packages
    })
  }
}

resource "proxmox_virtual_environment_vm" "proxmox_vm" {
    name      = var.vm_name
    node_name = var.node_name
    description = var.description
    tags        = var.tags

    stop_on_destroy = var.stop_on_destroy
    operating_system {
        type = var.operating_system_type
    }

    agent {
        enabled = var.agent_enabled
    }

    cpu {
        cores        = var.cpu_cores
        type         = var.cpu_type
    }

    memory {
        dedicated = var.memory_dedicated
    }

    initialization {
        dns {
            servers = var.dns_servers
        }

        ip_config {
            ipv4 {
                address = var.ip_address
                gateway = var.gateway
            } 
        }
        user_data_file_id = proxmox_virtual_environment_file.user_data_cloud.id
    }


    network_device {
        model = var.network_device_model
        bridge = var.network_device_bridge
    }

    depends_on = [proxmox_virtual_environment_file.user_data_cloud]
}