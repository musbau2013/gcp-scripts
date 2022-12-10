resource "google_compute_instance" "name" {
  name = "webser"
  machine_type = "e2_medium"
  zone = "us-cengtral1-a"
  boot_disk {
    
  }
}