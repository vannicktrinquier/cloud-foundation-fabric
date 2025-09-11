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

module "log-export-project" {
  source          = "../../../modules/project"
  name            = var.logging_project
  parent          = "folders/${var.folder}"
  billing_account = var.billing_account
  services = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com"
  ]

  # See https://discuss.google.dev/t/managing-multiple-google-cloud-projects-how-to-centralize-admin-activity-logs/169529 for explanation
  logging_sinks = {
    "activity-logs" : {
      destination = module.logging-bucket.id
      iam         = false
      filter      = <<-FILTER
          log_id("cloudaudit.googleapis.com/activity") OR
          log_id("cloudaudit.googleapis.com/system_event") OR
          log_id("cloudaudit.googleapis.com/policy") OR
          log_id("cloudaudit.googleapis.com/access_transparency")
          FILTER
      type        = "logging"
    }
  }
  factories_config = {
    observability = "data/observability"
    scc_custom_modules            = "data/scc-custom-modules"
  }

  scc_custom_modules = {
    kmsKeyRotationPeriod = {
      description    = "The rotation period of the identified cryptokey resource exceeds 30 days."
      recommendation = "Set the rotation period to at most 30 days."
      severity       = "MEDIUM"
      predicate = {
        expression = "resource.rotationPeriod > duration(\"2592000s\")"
      }
      resource_selector = {
        resource_types = ["cloudkms.googleapis.com/CryptoKey"]
      }
    }
  }
}


module "logging-bucket" {
  source = "../../../modules/logging-bucket"

  parent_type = "project"
  location    = var.location
  parent      = var.logging_project
  id          = "org-logging-bucket"
}

