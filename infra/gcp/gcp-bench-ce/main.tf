resource "google_compute_instance" "bench_instance" {
 name                    = join("-", [var.name_prefix, var.benchce_module_name_prefix, "instance"]) 
 machine_type            = var.benchce_machine_type
 zone                    = var.benchce_zone
 allow_stopping_for_update = true
 boot_disk {
    auto_delete = true
    initialize_params {
     image = var.benchce_image
     size  = var.benchce_size
     type  = "pd-standard"
   }
 }
metadata_startup_script = file("${path.module}/bench-setup.sh")

 network_interface {
   subnetwork = var.benchce_subnet

   access_config {
     nat_ip = var.benchce_natip
   }
 }

 service_account {
   scopes = ["userinfo-email", "compute-rw", "storage-rw"]
 }
 tags = ["pgvector-benchmarking", "benchce"]
 metadata = {
    ssh-keys = "${var.sshuser}:${tls_private_key.gcp_ssh_key.public_key_openssh}"
  }
}

resource "tls_private_key" "gcp_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Save the Private Key Locally
resource "local_file" "private_key" {
  content  = tls_private_key.gcp_ssh_key.private_key_pem
  filename = "${path.module}/gce_bench_privkey.pem"

  provisioner "local-exec" {
    command = "sudo chmod 600 ${path.module}/gce_bench_privkey.pem"
  }
}

resource "google_compute_resource_policy" "bench-policy" {
 name   = join("-", [var.name_prefix, var.benchce_module_name_prefix, "resource-policy"])
 region = var.benchce_region

 snapshot_schedule_policy {
  schedule {
    daily_schedule {
      days_in_cycle = 1
      start_time    = "02:00"
    }
  }

  retention_policy {
    max_retention_days    = 60
    on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
  }

  snapshot_properties {
    storage_locations = ["us"]
  }
 }
}