provider "google" {
  project     = "sumanth-97"
}

terraform {
  backend "gcs" {
    bucket  = "sumanth-state-backup-bucket"
    prefix  = "terraform/state"
  }
}

module "desktop-server" {
source = "/root/ASSESMENT/terraform-desktop/modules/desktop-server"
}
