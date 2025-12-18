# VCN configuration
resource "oci_core_vcn" "dokploy_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "network-dokploy-${random_string.resource_code.result}"
  dns_label      = "vcn${random_string.resource_code.result}"
}

# Subnet configuration
resource "oci_core_subnet" "dokploy_subnet" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_id
  display_name   = "subnet-dokploy-${random_string.resource_code.result}"
  dns_label      = "subnet${random_string.resource_code.result}"
  route_table_id = oci_core_vcn.dokploy_vcn.default_route_table_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id

  # Attach the security list
  security_list_ids = [oci_core_security_list.dokploy_security_list.id]
}

# Internet Gateway configuration
resource "oci_core_internet_gateway" "dokploy_internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = "Internet Gateway network-dokploy"
  enabled        = true
  vcn_id         = oci_core_vcn.dokploy_vcn.id
}

# Default Route Table
resource "oci_core_default_route_table" "dokploy_default_route_table" {
  manage_default_resource_id = oci_core_vcn.dokploy_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.dokploy_internet_gateway.id
  }
}

# Security List for Dokploy
resource "oci_core_security_list" "dokploy_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dokploy_vcn.id
  display_name   = "Dokploy Security List"

  # Public ingress (Traefik + Dokploy UI)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP traffic on port 80 (Traefik)"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
    description = "Allow HTTPS traffic on port 443 (Traefik)"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 3000
      max = 3000
    }
    description = "Allow Dokploy web interface on port 3000"
  }

  # Internal-only traffic (limit to subnet CIDR because security lists cannot reference subnet IDs)
  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    description = "Allow all internal traffic within the Dokploy subnet"
  }

  # Egress Rule (optional, if needed)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all egress traffic"
  }
}
