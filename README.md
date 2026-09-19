# Proxmox VM Module

Terraform module for creating a Proxmox virtual machine and attaching a rendered cloud-init user-data snippet.

The module:

- uploads a cloud-init YAML file to a Proxmox `snippets` datastore
- creates a virtual machine
- configures CPU, memory, QEMU guest agent, and networking
- attaches the uploaded user-data file to the VM initialization configuration

## Requirements

- Terraform 1.10 or later
- The `bpg/proxmox` provider
- A Proxmox datastore with the `Snippets` content type enabled
- SSH/API access for the Proxmox provider to upload snippets
- An Ubuntu cloud image with cloud-init installed

The provider documentation notes that snippet uploads use SSH access to the Proxmox node. The configured Proxmox storage must support snippets before this module is applied.

## Usage

```terraform
module "application_vm" {
  source = "github.com/gensdash/proxmox-vm.git?ref=v1.0.0"

  vm_name   = "application-vm"
  hostname  = "application-coding"
  node_name = "puebla"

  datastore_id = "local"
  ip_address   = "172.16.10.171/32"
  gateway      = "172.16.0.1"
  dns_servers  = ["172.16.0.1"]

  ssh_authorized_keys = [
    file("/root/.ssh/id_rsa.pub"),
    file("/root/.ssh/id_mac_rsa.pub"),
  ]

  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]

  cpu_cores        = 4
  cpu_type         = "x86-64-v2-AES"
  memory_dedicated = 8192
}
```

The module renders [`templates/cloud-init.yaml.tftpl`](templates/cloud-init.yaml.tftpl) with the hostname, username, SSH keys, timezone, and package list. The generated snippet is named `<vm_name>-user-data.yaml`.

## Inputs

| Name | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `vm_name` | `string` | yes | n/a | Proxmox VM name and prefix for the user-data filename. |
| `hostname` | `string` | yes | n/a | Hostname configured by cloud-init. |
| `node_name` | `string` | yes | n/a | Proxmox node hosting the VM and snippet. |
| `datastore_id` | `string` | yes | n/a | Datastore used for the cloud-init snippet. |
| `ip_address` | `string` | yes | n/a | VM IPv4 address, including prefix length. |
| `gateway` | `string` | yes | n/a | VM IPv4 gateway. |
| `dns_servers` | `list(string)` | yes | n/a | DNS servers passed to VM initialization. |
| `ssh_authorized_keys` | `list(string)` | yes | n/a | Public SSH keys installed for `username`. |
| `username` | `string` | no | `ubuntu` | Cloud-init user to create. |
| `timezone` | `string` | no | `America/Mexico_City` | Timezone configured by cloud-init. |
| `packages` | `list(string)` | no | `qemu-guest-agent`, `net-tools` | Packages installed during first boot. |
| `description` | `string` | no | `""` | Proxmox VM description. |
| `tags` | `set(string)` | no | `[]` | Proxmox VM tags. |
| `stop_on_destroy` | `bool` | no | `true` | Stop the VM before destruction. |
| `operating_system_type` | `string` | no | `l26` | Proxmox operating system type. |
| `agent_enabled` | `bool` | no | `true` | Enable the QEMU guest agent in Proxmox. |
| `cpu_cores` | `number` | no | `2` | Number of virtual CPU cores. |
| `cpu_type` | `string` | no | `host` | CPU type exposed to the VM. |
| `memory_dedicated` | `number` | no | `2048` | Memory in MiB. |
| `network_device_model` | `string` | no | `virtio` | Virtual network device model. |
| `network_device_bridge` | `string` | no | `vmbr0` | Proxmox bridge for the network device. |
| `content_type` | `string` | no | `snippets` | Proxmox content type for the user-data file. |
| `file_mode` | `string` | no | `0700` | File permissions variable retained for module compatibility. |

## Cloud-init behavior

The template currently intends to:

- create the configured user with password login locked
- install the configured packages
- configure the timezone
- enable and start `qemu-guest-agent`
- write a completion marker under `/run/cloud-init`

Cloud-init applies `runcmd` once per instance. Use Ansible or another configuration-management tool for ongoing configuration after first boot.

## Security and state

SSH public keys are not private credentials, but the rendered user-data content is stored in Terraform state by the Proxmox file resource. Protect the state file with a remote backend, encryption at rest, and access controls.

Do not put private SSH keys, passwords, API tokens, or other secrets in the template or module inputs. Terraform's `sensitive` flag redacts values from CLI output but does not remove them from state.

## Validation

From this module directory:

```bash
terraform fmt -check
terraform init
terraform validate
```

Validate the rendered cloud-init YAML separately when changing the template. A cloud-init-capable test VM is recommended before applying changes to production VMs.

## Current caveat

Before applying this module, review and correct the cloud-init template syntax and package names. The current template contains apparent typos in the `ssh_authorized_keys` boundary, QEMU guest-agent package/command name, and timezone key. The README documents the intended behavior, but Terraform validation alone will not validate cloud-init semantics.
