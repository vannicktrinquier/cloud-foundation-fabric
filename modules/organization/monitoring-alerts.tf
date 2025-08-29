
/**
 * Copyright 2022 Google LLC
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

locals {
  _monitoring_alerts_factory_path = pathexpand(coalesce(var.factories_config.monitoring_alerts, "-"))
  _monitoring_alerts_factory_data_raw = merge([
    for f in try(fileset(local._monitoring_alerts_factory_path, "*.yaml"), []) :
    yamldecode(file("${local._monitoring_alerts_factory_path}/${f}"))
  ]...)
  _monitoring_alerts_factory_data = {
    for k, v in local._monitoring_alerts_factory_data_raw : k => {
      display_name = v.display_name
      combiner     = v.combiner
      documentation = {
        content   = v.documentation.content
        mime_type = v.documentation.mime_type
      }
      conditions = [
        for c in v.conditions : {
          display_name = c.display_name
          condition_matched_log = {
            filter           = c.condition_matched_log.filter
            label_extractors = c.condition_matched_log.label_extractors
          }
        }
      ]
      notification_channels = v.notification_channels
      alert_strategy = {
        notification_rate_limit = {
          period = v.alert_strategy.notification_rate_limit.period
        }
        auto_close = v.alert_strategy.auto_close
      }
    }
  }
  _monitoring_alerts = merge(
    local._monitoring_alerts_factory_data,
  )
  monitoring_alerts = {
    for k, v in local._monitoring_alerts :
    templatestring(k, var.factories_config.context.monitoring_alerts) => merge(v, {
      name = k
      notification_channels = [
        for nc in v.notification_channels :
        templatestring(nc, var.factories_config.context.monitoring_alerts)
      ]
    })
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  provider = google-beta

  for_each = local.monitoring_alerts
  project  = var.factories_config.context.monitoring_alerts.project

  display_name = each.value.display_name
  combiner     = each.value.combiner

  documentation {
    content   = each.value.documentation.content
    mime_type = each.value.documentation.mime_type
  }

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name
      condition_matched_log {
        filter           = conditions.value.condition_matched_log.filter
        label_extractors = conditions.value.condition_matched_log.label_extractors
      }
    }
  }

  notification_channels = each.value.notification_channels
  alert_strategy {
    notification_rate_limit {
      period = each.value.alert_strategy.notification_rate_limit.period
    }
    auto_close = each.value.alert_strategy.auto_close
  }
}
