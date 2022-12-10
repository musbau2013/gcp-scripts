terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.45.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "my-project-id"
  region      = "us-central1"
  zone        = "us-central1-c"
}