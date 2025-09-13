module "security-project" {
  source          = "../../../modules/project"
  name            = var.security_project
  parent          = "folders/${var.folder}"
  billing_account = var.billing_account
  services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudkms.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}

module "kms" {
  source     = "../../../modules/kms"
  project_id = module.security-project.project_id
  keyring = {
    location = var.location
    name     = "security-key-ring"
  }
  keys = {
    key-sample = {}
  }
}
