provider "google" {
  project = "${var.gcp_project}"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_zone}"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-google-student${var.studentID}"
  machine_type = "${var.gcp_machine_type}"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }
  
  metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/workshop_key.pub")}"
        startup-script = <<SCRIPT
        sudo hostname terraform-instance-google-student${var.studentID}
        echo '127.0.1.1 terraform-instance-google-student${var.studentID}' | sudo tee -a /etc/hosts
        curl -fsSL https://get.docker.com/ | sh
        sudo usermod -aG docker ubuntu
        SCRIPT
    }

  network_interface {
    network       = "default"
    access_config {
    }
  }
}

resource "google_dns_record_set" "a" {
  name = "${var.studentID}.tf.google.gluo.cloud."
  managed_zone = "google-gluo-cloud"
  type = "A"
  ttl  = 60

  rrdatas = ["${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"]
}

/* Ports openzetten
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network-student${var.studentID}"
  auto_create_subnetworks = "true"
}
*/

output "ip" {
 value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}
