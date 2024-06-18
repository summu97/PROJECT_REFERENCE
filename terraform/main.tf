provider "google" {
  project     = "sumanth-97"
}

module "jenkins-server" {
source = "/root/ASSESMENT/terraform-jenkins/modules/jenkins-server"
}
