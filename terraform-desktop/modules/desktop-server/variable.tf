variable "machine_type" {
type = string
default = "n2-standard-2"
}

variable "name" {
type = string
default = "desktop-server"
}

variable "zone" {
type = string
default = "us-west1-b"
}

variable "image" {
type = string
default = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
}
