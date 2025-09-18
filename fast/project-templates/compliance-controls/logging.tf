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

module "logging-project" {
  source          = "../../../modules/project"
  name            = var.logging_project.name
  parent          = var.logging_project.parent
  billing_account = var.billing_account

  project_reuse = var.logging_project.project_reuse == true ? {
    use_data_source = true
    attributes = {
      name : var.logging_project.name,
      number : var.logging_project.number
    }
  } : null

  services = toset(concat([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
  ], var.logging_project.services == null ? [] : var.logging_project.services))

  service_encryption_key_ids = merge({
    "compute.googleapis.com" = [module.kms.key_ids["key-${var.location}"]]
    "pubsub.googleapis.com"  = [module.kms.key_ids["key-${var.location}"]]
    }, (var.logging_project.services != null ?
    { for service in var.logging_project.services : service => [module.kms.key_ids["key-${var.location}"]] } : {}
  ))

  logging_sinks = {
    "activity-logs" : {
      destination = module.audit-logs-bucket.id
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

  notification_channels = {
    alert-notification-channel = {
      display_name = "Monitoring Alert Notification Channel"
      type         = "pubsub"

      labels = {
        topic = google_pubsub_topic.notification_channel_topic.id
      }
    }
  }
}

module "audit-logs-bucket" {
  source       = "../../../modules/logging-bucket"
  parent_type  = "project"
  location     = var.location
  parent       = module.logging-project.project_id
  name         = "audit-logs-bucket"
  kms_key_name = module.kms.key_ids["key-${var.location}"]

  depends_on = [google_kms_crypto_key_iam_member.service_agent_cmek]
}

resource "google_project_service_identity" "logging_agent" {
  provider = google-beta
  project  = module.logging-project.project_id
  service  = "logging.googleapis.com"
}

# Needed to ensure logging service account managed CMEK is created
data "google_logging_project_cmek_settings" "logging_cmek_settings" {
  project = module.logging-project.project_id

  depends_on = [google_project_service_identity.logging_agent]
}

# Provide delay to ensure logging service account is created before assigning permissions
resource "time_sleep" "wait_for_sa_propagation" {
  create_duration = "30s"

  depends_on = [
    data.google_logging_project_cmek_settings.logging_cmek_settings
  ]
}

resource "google_kms_crypto_key_iam_member" "service_agent_cmek" {
  crypto_key_id = module.kms.key_ids["key-${var.location}"]
  member        = "serviceAccount:service-${module.logging-project.number}@gcp-sa-logging.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  depends_on = [google_project_service_identity.logging_agent, time_sleep.wait_for_sa_propagation]
}


