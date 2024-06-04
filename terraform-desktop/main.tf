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
source = "/home/jenkins/workspace/pipeline-1/terraform-desktop/modules/desktop-server"
}
