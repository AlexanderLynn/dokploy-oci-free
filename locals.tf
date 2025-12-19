locals {
  instance_config = {
    shape = var.instance_shape
    shape_config = {
      ocpus         = var.ocpus
      memory_in_gbs = var.memory_in_gbs
    }
    source_details = {
      source_id               = var.source_image_id
      source_type             = "image"
      boot_volume_size_in_gbs = var.boot_volume_size_gb
    }
  }
}
