provider "google" {
  project     = "sumanth-97"
}

module "jenkins-server" {
source = "/terraform-jenkins/modules/jenkins-server"
}
