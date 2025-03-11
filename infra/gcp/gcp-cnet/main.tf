resource "google_compute_network" "bench_compute_network" {
  auto_create_subnetworks = var.cnet_auto_subnet_create 
  name                    = join("-", [var.name_prefix, var.cnet_module_name_prefix, "net"]) 
  routing_mode            = var.cnet_routing_mode 
}

resource "google_compute_subnetwork" "pgbench_subnets" {
  name          = join("-", [var.name_prefix, var.cnet_module_name_prefix, "subnet"])
  ip_cidr_range = var.cnet_cidr_range 
  region        = var.cnet_region 
  network       = google_compute_network.bench_compute_network.id
}

resource "google_compute_address" "pgbench_address" {
  name   = join("-", [var.name_prefix, var.cnet_module_name_prefix, "ip-address"])
  region = var.cnet_region 
  address_type = "EXTERNAL"
  ip_version = "IPV4"
  labels = {
    createdfor = "benchce-external-ip"
  }
}

resource "google_compute_address" "benchce_address" {
  name   = join("-", [var.name_prefix, var.cnet_module_name_prefix, "benchce-ip"])
  region = var.cnet_region 
  address_type = "EXTERNAL"
  ip_version = "IPV4"
  labels = {
    createdfor = "benchce-external-ip"
  }
}

resource "google_compute_address" "dbce_address" {
  name   = join("-", [var.name_prefix, var.cnet_module_name_prefix, "dbce-ip"])
  region = var.cnet_region 
  address_type = "EXTERNAL"
  ip_version = "IPV4"
  labels = {
    createdfor = "dbce-external-ip"
  }
}

resource "google_compute_global_address" "db_private_ip" {
  provider = google

  name          = join("-", [var.name_prefix, var.cnet_module_name_prefix, "private-ip"])
  purpose       = var.cnet_compute_address_purpose 
  address_type  = var.cnet_compute_address_type 
  prefix_length = var.cnet_compute_address_prefix_length 
  network       = google_compute_network.bench_compute_network.id
}

resource "google_compute_firewall" "cloudsql_ingress" {
  name    = join("-", [var.name_prefix, var.cnet_module_name_prefix, "cloudsql-rule"])
  network = google_compute_network.bench_compute_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = var.cnet_compute_firewall_source_ranges 
}

resource "google_compute_firewall" "bench_ingress_ssh" {
  name    = join("-", [var.name_prefix, var.cnet_module_name_prefix, "bench-ssh"])
  network = google_compute_network.bench_compute_network.id

  allow {
    protocol = var.cnet_compute_firewall_allow_protocol[0] 
    ports    = ["22"] 
  }

  source_ranges = var.cnet_compute_firewall_source_ranges 
}

resource "google_compute_firewall" "cedb_ingress_ssh" {
  name    = join("-", [var.name_prefix, var.cnet_module_name_prefix, "db-ssh"])
  network = google_compute_network.bench_compute_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.cnet_compute_firewall_source_ranges 
}

resource "google_compute_firewall" "cedb_ingress" {
  name    = join("-", [var.name_prefix, var.cnet_module_name_prefix, "sqldb-rule"])
  network = google_compute_network.bench_compute_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = var.cnet_compute_firewall_source_ranges 
}

