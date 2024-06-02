provider "google" {
  project     = "sumanth-97"
}

module "jenkins-server" {
source = "/root/terraform-jenkins/modules/jenkins-server"
}
