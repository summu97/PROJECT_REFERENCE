provider "google" {
  project     = "sumanth-97"
}

module "desktop-server" {
source = "/terraform-desktop/modules/desktop-server"
}
