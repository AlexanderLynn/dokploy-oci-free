# VCN
resource "oci_core_vcn" "dokploy_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "dokploy-vcn-${random_string.resource_code.result}"
  dns_label      = "vcn${random_string.resource_code.result}"
}

# Subnet
resource "oci_core_subnet" "dokploy_subnet" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "dokploy-subnet-${random_string.resource_code.result}"
  dns_label      = "subnet${random_string.resource_code.result}"
  route_table_id = oci_core_vcn.dokploy_vcn.default_route_table_id

  security_list_ids = var.use_cloudflare_tunnels ? [
    oci_core_security_list.dokploy_base.id
  ] : [
    oci_core_security_list.dokploy_base.id,
    oci_core_security_list.dokploy_web[0].id
  ]
}

# Internet Gateway
resource "oci_core_internet_gateway" "dokploy_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "dokploy-igw-${random_string.resource_code.result}"
  enabled        = true
}

# Default Route Table
resource "oci_core_default_route_table" "dokploy_route_table" {
  manage_default_resource_id = oci_core_vcn.dokploy_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.dokploy_igw.id
  }
}

# Base Security List (internal traffic only)
resource "oci_core_security_list" "dokploy_base" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "dokploy-base-sl-${random_string.resource_code.result}"

  # Allow all internal subnet traffic
  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    description = "Allow all internal traffic within subnet"
  }

  # Allow all egress
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all egress"
  }
}

# Web Security List (ports 80/443) - only created when NOT using Cloudflare Tunnels
resource "oci_core_security_list" "dokploy_web" {
  count          = var.use_cloudflare_tunnels ? 0 : 1
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "dokploy-web-sl-${random_string.resource_code.result}"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
    description = "HTTP"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
    description = "HTTPS"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# NSG for Dokploy main UI (port 3000) - attached only to main instance
resource "oci_core_network_security_group" "dokploy_main_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "dokploy-main-nsg-${random_string.resource_code.result}"
}

resource "oci_core_network_security_group_security_rule" "dokploy_main_port_3000" {
  network_security_group_id = oci_core_network_security_group.dokploy_main_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 3000
      max = 3000
    }
  }
  description = "Dokploy web interface"
}
