variable "ssh_authorized_keys" {
  description = "SSH public key for instance access. Example: ssh-rsa AAAAB3Nza... user@host"
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment. Find it: Profile → Tenancy: youruser → Tenancy information → OCID"
  type        = string
}

variable "source_image_id" {
  description = "Ubuntu 24.04 LTS Minimal image OCID. Find the right one for your region at: https://docs.oracle.com/en-us/iaas/images/"
  type        = string
}

variable "availability_domain_main" {
  description = "Availability domain for the main Dokploy instance. Example: Ukbr:PHX-AD-1"
  type        = string
}

variable "availability_domain_workers" {
  description = "List of availability domains for worker instances. Workers are distributed round-robin across these ADs. Example: [\"Ukbr:PHX-AD-1\", \"Ukbr:PHX-AD-2\"]"
  type        = list(string)

  validation {
    condition     = length(var.availability_domain_workers) > 0
    error_message = "At least one availability domain must be specified for workers."
  }
}

variable "num_worker_instances" {
  description = "Number of Dokploy worker instances to deploy (max 3 for free tier)."
  type        = number
  default     = 1
}

variable "use_cloudflare_tunnels" {
  description = "If true, ports 80/443 are NOT opened on any instance. Only port 3000 on main is exposed."
  type        = bool
  default     = false
}

variable "instance_shape" {
  description = "Compute shape. VM.Standard.A1.Flex is free tier eligible."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Number of OCPUs per instance. Free tier: up to 4 total across all A1 instances."
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Memory in GB per instance. Free tier: up to 24 GB total across all A1 instances."
  type        = number
  default     = 6
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB. Free tier: up to 200 GB total."
  type        = number
  default     = 50
}
