terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.2.0"
    }
  }
}

provider "google" {
  project = var.project_name
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_name" {
  description = "The name of the GCP project"
  type        = string
}

variable "billing_account" {
  description = "billing account ID"
  type        = string
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_name
  billing_account = var.billing_account
}

resource "google_project_service" "compute" {
  project            = google_project.project.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry" {
  project = google_project.project.project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "kubernetes_engine" {
  project = google_project.project.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}

resource "google_storage_bucket" "vm_images_bucket" {
  name     = "${var.resource_prefix}-images"
  location = "EU"
  project  = google_project.project.project_id
}

resource "google_artifact_registry_repository" "docker_repository" {
  location      = "europe"
  repository_id = "${var.resource_prefix}-docker-repository"
  description   = "Docker repository"
  format        = "DOCKER"
  project       = google_project.project.project_id
}

resource "google_container_cluster" "primary" {
  name     = "${var.resource_prefix}-cluster"
  location = "europe-central2-a"

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  project                  = google_project.project.project_id
  network                  = google_compute_network.ilb_network.id
  subnetwork               = google_compute_subnetwork.ilb_subnet.id
  service_external_ips_config {
    enabled = false
  }
}

resource "google_container_node_pool" "primary" {
  name       = "${var.resource_prefix}-node-pool"
  location   = "europe-central2-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
    disk_size_gb = 15

  }
  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  project = google_project.project.project_id
}

# VPC network
resource "google_compute_network" "ilb_network" {
  name                    = "${var.resource_prefix}-l7-ilb-network"
  auto_create_subnetworks = false
  project                 = google_project.project.project_id
}

# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "${var.resource_prefix}-l7-ilb-proxy-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-central2"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.ilb_network.id
}

# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "${var.resource_prefix}-7-ilb-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-central2"
  network       = google_compute_network.ilb_network.id
}

## Static IP Address
resource "google_compute_address" "static_ip" {
  name    = "${var.resource_prefix}-static-ip"
  project = google_project.project.project_id
  region  = "europe-central2"
}

## VM Instance

resource "google_compute_instance" "vm_instance" {
  name         = "${var.resource_prefix}-instance"
  machine_type = "n1-standard-16"
  project      = google_project.project.project_id

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240515"
    }
  }

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  depends_on = [google_project_service.compute]
}


## Autoscaling instances
resource "google_compute_instance_template" "template" {
  name_prefix  = "${var.resource_prefix}-template-"
  machine_type = "n1-standard-2"
  project      = google_project.project.project_id

  disk {
    source_image = "bbdays4it"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id

  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  metadata = {
    serial-port-enable = "1"
  }
}

resource "google_compute_instance_template" "template_v2" {
  name_prefix  = "${var.resource_prefix}-template-v1"
  machine_type = "n1-standard-2"
  project      = google_project.project.project_id

  disk {
    source_image = "it-craft-2024-v5"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id

  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  metadata = {
    serial-port-enable = "1"
  }
}
resource "google_compute_instance_group_manager" "manager" {
  name               = "${var.resource_prefix}-instance-group-manager"
  project            = google_project.project.project_id
  base_instance_name = "instance"
  zone               = "europe-central2-a"
  version {
    instance_template = google_compute_instance_template.template.self_link
  }
  named_port {
    name = "http"
    port = 8080
  }
  target_size = 0

  update_policy {
    type                  = "OPPORTUNISTIC"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
  }
}

# resource "google_compute_autoscaler" "autoscaler" {
#   name    = "${var.resource_prefix}-autoscaler"
#   project = google_project.project.project_id
#   zone    = "europe-central2-a"

#   target = google_compute_instance_group_manager.manager.self_link

#   autoscaling_policy {
#     max_replicas    = 10
#     min_replicas    = 0
#     cooldown_period = 15

#     cpu_utilization {
#       target = 0.5
#     }
#   }
# }

resource "google_compute_health_check" "default" {

  name                = "${var.resource_prefix}-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 4
  unhealthy_threshold = 5
  http_health_check {
    port         = 8080
    request_path = "/"
  }
}

resource "google_compute_region_backend_service" "default" {
  name                            = "${var.resource_prefix}-backend-service"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 5
  connection_draining_timeout_sec = 5
  load_balancing_scheme           = "INTERNAL_MANAGED"
  health_checks                   = [google_compute_health_check.default.self_link]
  backend {
    group           = google_compute_instance_group_manager.manager.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_url_map" "default" {
  name            = "${var.resource_prefix}-url-map"
  region          = "europe-central2"
  default_service = google_compute_region_backend_service.default.self_link
}

resource "google_compute_region_target_http_proxy" "default" {
  name    = "${var.resource_prefix}-http-proxy"
  url_map = google_compute_region_url_map.default.self_link
  region  = "europe-central2"

}

resource "google_compute_address" "ip_address" {
  name         = "${var.resource_prefix}-it-lb-address"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.ilb_subnet.id
}


resource "google_compute_forwarding_rule" "default" {
  name                  = "forwarding-rule"
  target                = google_compute_region_target_http_proxy.default.self_link
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_address            = google_compute_address.ip_address.address
  region                = "europe-central2"
  network               = google_compute_network.ilb_network.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
}

resource "google_compute_firewall" "default" {
  name    = "${var.resource_prefix}-firewall-rule"
  network = google_compute_network.ilb_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "fw-iap" {
  name          = "${var.resource_prefix}-l7-ilb-fw-allow-iap-hc"
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}
