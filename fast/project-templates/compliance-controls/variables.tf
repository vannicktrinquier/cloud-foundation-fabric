# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "billing_account" {
  description = "The billing account."
  type        = string
}
variable "controls_folder" {
  description = "The folder where controls are stored."
  type        = string
}

variable "location" {
  description = "The location."
  type        = string
}

variable "logging_project" {
  description = "The logging project ID where to create log metrics and alerts."
  type = object({
    parent        = string
    name          = string
    number        = optional(number)
    project_reuse = optional(bool, false)
  })
}

variable "log_sinks" {
  description = "Org-level log sinks, in name => {type, filter} format."
  type = map(object({
    filter     = string
    disabled   = optional(bool, false)
    exclusions = optional(map(string), {})
  }))
  nullable = false
  default = {
    audit-logs = {
      filter = <<-FILTER
        log_id("cloudaudit.googleapis.com/activity") OR
        log_id("cloudaudit.googleapis.com/system_event") OR
        log_id("cloudaudit.googleapis.com/policy") OR
        log_id("cloudaudit.googleapis.com/access_transparency")
      FILTER
      exclusions = {
        gke-audit = "protoPayload.serviceName=\"k8s.io\""
      }
    }
  }
}

variable "organization" {
  description = "Organization details."
  type = object({
    id          = number
    domain      = optional(string)
    customer_id = optional(string)
  })
}

variable "security_project" {
  description = "The security project ID where to manage encryption keys."
  type = object({
    parent        = string
    name          = string
    number        = optional(number)
    project_reuse = optional(bool, false)
  })
}

variable "target_folders" {
  description = "A list of folder IDs to apply controls to."
  type        = list(string)
  default     = []
}

variable "target_organization" {
  description = "Set to true to apply controls at the organization level."
  type        = bool
  default     = false
}
variable "target_projects" {
  description = "A list of project IDs to apply controls to."
  type = list(object({
    name   = string
    number = number
  }))
  default = []
}