provider "google" {
  project     = "sumanth-97"
}

module "desktop-server" {
source = "/home/jenkins/workspace/pipeline-1/terraform-desktop/modules/desktop-server"
}
