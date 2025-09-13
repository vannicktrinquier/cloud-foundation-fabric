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

# tfdoc:file:description Audit log project and sink.

module "log-export-project" {
  source          = "../../../modules/project"
  count           = var.logging_project != null ? 1 : 0
  name            = var.logging_project
  parent          = "folders/${var.folder}"
  billing_account = var.billing_account
  services = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "run.googleapis.com",
  ]

  service_encryption_key_ids = {
    "compute.googleapis.com" = [module.kms.key_ids["key-sample"]]
    "storage.googleapis.com" = [module.kms.key_ids["key-sample"]]
    "run.googleapis.com"     = [module.kms.key_ids["key-sample"]]
  }

  context = {
    notification_channels = {
      "alert-channel" = "projects/fsi-foundation-logging-d877/notificationChannels/17922446472344305309"
    }

    logging_bucket_names = {
      "org-bucket" = "projects/${var.logging_project}/locations/${var.location}/buckets/org-logging-bucket"
    }
  }

  # See https://discuss.google.dev/t/managing-multiple-google-cloud-projects-how-to-centralize-admin-activity-logs/169529 for explanation
  logging_sinks = {
    "activity-logs" : {
      destination = module.logging-bucket[0].id
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
    observability      = "data/observability"
    scc_custom_modules = "data/scc-custom-modules"
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

  # notification_channels = {
  #   alert-notification-channel = {
  #     display_name = "Monitoring Alert Notification Channel"
  #     type         = "pubsub"

  #     labels = {
  #       email_address = "hello@example.com"
  #     }

  #   }
  # }

}

module "logging-bucket" {
  source       = "../../../modules/logging-bucket"
  count        = var.logging_project != null ? 1 : 0
  parent_type  = "project"
  location     = var.location
  parent       = module.log-export-project[0].project_id
  name         = "org-logging-bucket"
  kms_key_name = module.kms.key_ids["key-sample"]

  depends_on = [google_kms_crypto_key_iam_member.service_agent_cmek]
}

data "google_logging_project_cmek_settings" "logging_cmek_settings" {
  count   = var.logging_project != null ? 1 : 0
  project = module.log-export-project[0].project_id

  depends_on = [google_project_service_identity.logging_agent]
}

resource "google_project_service_identity" "logging_agent" {
  provider = google-beta
  count    = var.logging_project != null ? 1 : 0

  project = module.log-export-project[0].project_id
  service = "logging.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "service_agent_cmek" {
  count = var.logging_project != null ? 1 : 0

  crypto_key_id = module.kms.key_ids["key-sample"]
  member        = "serviceAccount:service-${module.log-export-project[0].number}@gcp-sa-logging.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  depends_on    = [google_project_service_identity.logging_agent]
}
