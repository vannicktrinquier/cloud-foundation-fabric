provider "google" {
  billing_project       = var.billing_project
  project               = var.project
  user_project_override = true
}

provider "google-beta" {
  billing_project       = var.billing_project
  project               = var.project
  user_project_override = true
}
