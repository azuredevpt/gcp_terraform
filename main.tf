  variable project{
   default = 
   "us-central1-c"	
 }

  variable region{
   default = 
   "us-central1-c"	
 }

 variable zone{
   description = "zone google du projet"
   type = "string"
   default = "us-central1-c"	
 }

 provider "google" {
  credentials = "${file("credentials.json")}"
  project     = "${var.project}"	
  region      = "${var.region}"	
  zone      = "${var.zone}"	
}

 variable ports_inbounds{
   description = "ports accéssibles en entrée"
   type = "list"
   default =["22","80"]
 }

#provider "aws" {
#  region      = "eu-west-3"
#  access_key  = ""
#  key_key         = ""
#}


resource "google_compute_instance" "hdp_vm1" {

  name         = "hadoop-vm1"
  machine_type = "n1-standard-1"
 
 #tags{
  #name = "NoeudHadoop"
#} 

  #tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }
#for aws only
#key_name = ""

metadata = {
   ssh-keys = "useradmin:${file("~/.ssh/id_rsa.pub")}"
  
 }

metadata_startup_script = "${file("startup.ign")}"

network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "${google_compute_network.vpc_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = "${var.ports_inbounds}"
  }

}