variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "vsphere_datacenter" {}
variable "vsphere_datastore" {}
variable "vsphere_resource_pool" {}
variable "vsphere_network" {}
variable "vm_template" {}
variable "vm_count" {}
variable "vm_name" {}
variable "vm_vcpu" {}
variable "vm_memory" {}
variable "vm_disk1_size" {}
variable "vm_domain" {}
variable "vm_time_zone" {}
variable "ssh_user" {}

terraform {
  required_version = ">= 0.12"
}

provider "vsphere" {
  version        = "~> 1.12"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vsphere_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  count            = "${var.vm_count}"
  name             = "${var.vm_name}${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = "${var.vm_vcpu}"
  memory   = "${var.vm_memory}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id     = "${data.vsphere_network.network.id}"
    adapter_type   = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    use_static_mac = true
    mac_address    = "${lookup(var.vm_mac_address, "mac_address${count.index + 1}")}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  disk {
    label            = "disk1"
    size             = "${var.vm_disk1_size}"
    eagerly_scrub    = false
    thin_provisioned = true
    unit_number      = 1
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${var.vm_name}${count.index + 1}"
        domain    = "${var.vm_domain}"
        time_zone = "${var.vm_time_zone}"
      }

      network_interface {}
    }
  }

  provisioner "file" {
    source      = "../packages/"
    destination = "/home/${var.ssh_user}"
  }

  # Run commands with remote-exec over ssh
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.vm_name}${count.index + 1}.${var.vm_domain}",
      "chmod 640 /home/${var.ssh_user}/*.rpm"
    ]
  }

  connection {
    type        = "ssh"
    host        = "${self.default_ip_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
    user        = "${var.ssh_user}"
    agent       = false
  }

  provisioner "local-exec" {
    command = "ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' -u ${var.ssh_user} --private-key ~/.ssh/id_rsa -i ../ansible/inventory ../ansible/playbook.yml"
  }
}
