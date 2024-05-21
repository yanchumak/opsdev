terraform {
  backend "remote" {
    organization = "home-sandbox"

    workspaces {
      name = "opsdev"
    }
  }
}