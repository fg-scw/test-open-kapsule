terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.41.1"
    }
  }
}

provider "scaleway" {
  zone   = "fr-par-2"
  region = "fr-par"
}
