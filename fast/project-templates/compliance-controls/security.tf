/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES, OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module "security-project" {
  source          = "../../../modules/project"
  name            = var.security_project.name
  parent          = "folders/${var.folder}"
  billing_account = var.billing_account

  project_reuse = var.security_project.project_reuse == true ? {
    use_data_source = true
    attributes = {
      name : var.security_project.name,
      number : var.security_project.number
    }
  } : null

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
