resource "google_compute_instance" "desktop-server" {
  name         = "desktop-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        my_label = "desktop-server"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "projects/sumanth-97/global/networks/custom-vpc"
    subnetwork = "projects/sumanth-97/regions/us-west1/subnetworks/desktop-server-subnet"

    access_config {
      // Ephemeral IP
    }
  }

  labels = {
    desktop-server = "true"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "custom-svc@sumanth-97.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = [var.name]  # Add network tags

  metadata = {
    ssh-keys = "root:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
  } 

resource "google_compute_instance" "apache2" {
  name         = "apache2"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        my_label = "apache2"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "projects/sumanth-97/global/networks/custom-vpc"
    subnetwork = "projects/sumanth-97/regions/us-west1/subnetworks/desktop-server-subnet"

    access_config {
      // Ephemeral IP
    }
  }

  labels = {
    apache2 = "true"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "custom-svc@sumanth-97.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = [var.name]  # Add network tags

  metadata = {
    ssh-keys = "root:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
  } 
}
