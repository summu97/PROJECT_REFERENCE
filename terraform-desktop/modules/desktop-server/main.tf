resource "google_compute_instance" "desktop-server" {
  name         = "${terraform.workspace}-desktop-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        my_label = "${terraform.workspace}"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "projects/sumanth-97/global/networks/default-vpc"
    subnetwork = "projects/sumanth-97/regions/us-west1/subnetworks/default-desktop-server-subnet"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "default-svc@sumanth-97.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = [var.name]  # Add network tags

  metadata = {
    ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y git
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2/' /etc/ssh/sshd_config
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF
}
