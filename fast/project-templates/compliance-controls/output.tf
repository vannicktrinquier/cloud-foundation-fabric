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

output "notification_channel" {
  description = "Notification channel created"
  value       = module.logging-project.notification_channels["alert-notification-channel"].id
}

output "pubsub_topic" {
  description = "Pub/Sub topic for monitoring alerts"
  value       = google_pubsub_topic.notification_channel_topic.id
}

output "logging_project_id" {
  description = "Logging project id"
  value       = module.logging-project.project_id
}

output "security_project_id" {
  description = "Security project id"
  value       = module.security-project.project_id
}
