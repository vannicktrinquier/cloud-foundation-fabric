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

output "custom_constraints" {
  description = "Custom constraints deployed."
  value       = module.organization.custom_constraint_ids
}

output "kms_key" {
  description = "KMS key created"
  value       = module.kms.key_ids["key-sample"]
}

output "logging_project_id" {
  description = "Logging project id"
  value       = module.logging-project.project_id
}

output "monitoring_alerts" {
  description = "Monitoring alerts deployed."
  value       = module.monitoring-alerts-project.alert_ids
}

output "notification_channel" {
  description = "Notification channel created"
  value       = module.logging-project.notification_channels["alert-notification-channel"].id
}

output "pubsub_topic" {
  description = "Pub/Sub topic for monitoring alerts"
  value       = google_pubsub_topic.notification_channel_topic.id
}

output "organization_policies_ids" {
  description = "Map of organization policies with parent as key and list of ids as value"
  value = merge(
    var.target_organization ? {
      "organizations/${var.organization.id}" = module.control-organization.organization_policies_ids
    } : {},
    {
      for f in var.target_folders : "folders/${f}" => module.target_folders[f].organization_policies_ids
    },
    {
      for p in var.target_projects : "projects/${p.name}" => module.target-projects[p.name].organization_policies_ids
    }
  )
}

output "scc_custom_sha_modules_ids" {
  description = "Map of SCC custom security health analytics modules with parent as key and list of ids as value"
  value = merge(
    var.target_organization ? {
      "organizations/${var.organization.id}" = module.control-organization.scc_custom_sha_modules_ids
    } : {},
    {
      for f in var.target_folders : "folders/${f}" => module.target_folders[f].scc_custom_sha_modules_ids
    },
    {
      for p in var.target_projects : "projects/${p.name}" => module.target-projects[p.name].scc_custom_sha_modules_ids
    }
  )
}

output "security_project_id" {
  description = "Security project id"
  value       = module.security-project.project_id
}
