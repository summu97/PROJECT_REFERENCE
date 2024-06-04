module "networking" {
source = "/root/terraform-jenkins/modules/networking"
}

module "service-account" {
source = "/root/terraform-jenkins/modules/service-account"
}

resource "google_compute_instance" "bastion" {
  name         = "${terraform.workspace}-jenkins-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20 # Size in GB
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
    network = module.networking.network_self_link
    subnetwork = module.networking.subnetwork_self_link

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = module.service-account.svc_email
    scopes = ["cloud-platform"]
  }

  tags = [var.name]  # Add network tags

  metadata_startup_script = <<-EOF
  #! /bin/bash
    sudo apt-get update
    sudo apt install git -y
    sudo apt install -y openjdk-17-jre wget vim

    # Install Jenkins
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    # Installing docker
    sudo apt install docker.io -y
    sudo sed -i '14s|.*|ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock|' /lib/systemd/system/docker.service
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    # Install Ansible
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
    sudo hostnamectl set-hostname ansible-master
    echo 'root:password' | sudo chpasswd
    # Modifying config file
    sudo sed -i '34s|.*|PermitRootLogin yes|' /etc/ssh/sshd_config
    sudo sed -i '58s|.*|PasswordAuthentication yes|' /etc/ssh/sshd_config
    sudo sed -i '42s|.*|AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2|' /etc/ssh/sshd_config
    sudo sed -i '39s|.*|PubkeyAuthentication yes|' /etc/ssh/sshd_config
    sudo sed -i '15s|.*|Port 22|' /etc/ssh/sshd_config

    # Restart and check status of sshd
    systemctl restart sshd
    systemctl status sshd
  EOF
}
