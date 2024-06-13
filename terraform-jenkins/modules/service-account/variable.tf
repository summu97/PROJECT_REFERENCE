variable "project_id" {
description = "custom-svc"
type = string
default = "sumanth-97"
}

variable "roles" {
  default = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/compute.instanceAdmin",
    "roles/storage.admin",
    "roles/compute.viewer"
  ]
}
