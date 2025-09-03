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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Audit log project and sink.

locals {
  log_sink_destinations = merge(
    module.log-export-logbucket
  )
}

module "log-export-project" {
  source = "../../../modules/project"
  name   = var.logging_project
  parent = "folders/${var.folder}"
  billing_account = var.billing_account
  services = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}

module "log-export-logbucket" {
  source        = "../../../modules/logging-bucket"
  for_each      = toset([for k, v in var.log_sinks : k])
  parent_type   = "project"
  parent        = module.log-export-project.project_id
  id            = each.key
  location      = var.location
  log_analytics = { enable = true }
  kms_key_name  = module.kms.key_ids.key-sample
  # org-level logging settings ready before we create any logging buckets
#   depends_on = [module.organization-logging]
}
