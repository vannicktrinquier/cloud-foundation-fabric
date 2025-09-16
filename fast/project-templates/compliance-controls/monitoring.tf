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

resource "google_pubsub_topic" "notification_channel_topic" {
  name         = "monitoring-alert-topic"
  project      = module.logging-project.project_id
  kms_key_name = module.kms.key_ids["key-sample"]
}

module "monitoring-alerts-project" {
  source = "../../../modules/project"
  name   = var.logging_project.name
  project_reuse = {
    use_data_source = false
    attributes = {
      name   = module.logging-project.name
      number = module.logging-project.number
    }
  }
  context = {
    notification_channels = {
      "alert-channel" = module.logging-project.notification_channels["alert-notification-channel"].id
    }
    logging_bucket_names = {
      "org-bucket" = module.logging-bucket.id
    }
  }
  factories_config = {
    observability = "${var.controls_folder}/observability"
  }

  depends_on = [module.logging-project]
}
