# Main Dokploy instance
resource "oci_core_instance" "dokploy_main" {
  display_name        = "dokploy-main-${random_string.resource_code.result}"
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain_main
  shape               = local.instance_config.shape

  shape_config {
    ocpus         = local.instance_config.shape_config.ocpus
    memory_in_gbs = local.instance_config.shape_config.memory_in_gbs
  }

  source_details {
    source_id               = local.instance_config.source_details.source_id
    source_type             = local.instance_config.source_details.source_type
    boot_volume_size_in_gbs = local.instance_config.source_details.boot_volume_size_in_gbs
  }

  create_vnic_details {
    display_name   = "dokploy-main-vnic-${random_string.resource_code.result}"
    subnet_id      = oci_core_subnet.dokploy_subnet.id
    nsg_ids        = [oci_core_network_security_group.dokploy_main_nsg.id]
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(file("${path.module}/bin/dokploy-main.sh"))
  }

  depends_on = [
    oci_core_vcn.dokploy_vcn,
    oci_core_subnet.dokploy_subnet,
    oci_core_internet_gateway.dokploy_igw,
    oci_core_default_route_table.dokploy_route_table,
  ]
}

# Worker instances
resource "oci_core_instance" "dokploy_worker" {
  count = var.num_worker_instances

  display_name        = "dokploy-worker-${count.index + 1}-${random_string.resource_code.result}"
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain_workers[count.index % length(var.availability_domain_workers)]
  shape               = local.instance_config.shape

  shape_config {
    ocpus         = local.instance_config.shape_config.ocpus
    memory_in_gbs = local.instance_config.shape_config.memory_in_gbs
  }

  source_details {
    source_id               = local.instance_config.source_details.source_id
    source_type             = local.instance_config.source_details.source_type
    boot_volume_size_in_gbs = local.instance_config.source_details.boot_volume_size_in_gbs
  }

  create_vnic_details {
    display_name     = "dokploy-worker-${count.index + 1}-vnic-${random_string.resource_code.result}"
    subnet_id        = oci_core_subnet.dokploy_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  depends_on = [
    oci_core_vcn.dokploy_vcn,
    oci_core_subnet.dokploy_subnet,
    oci_core_internet_gateway.dokploy_igw,
    oci_core_default_route_table.dokploy_route_table,
  ]
}
