
variable "organization" {
  description = "Organization details."
  type = object({
    id          = number
    domain      = optional(string)
    customer_id = optional(string)
  })
}

variable "billing_project" {
  description = "The billing project ID."
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

variable "billing_account" {
  description = "The billing account."
  type        = string
}

variable "target_organization" {
  description = "Set to true to apply controls at the organization level."
  type        = bool
  default     = false
}

variable "target_folders" {
  description = "A list of folder IDs to apply controls to."
  type        = list(string)
  default     = []
}

variable "target_projects" {
  description = "A list of project IDs to apply controls to."
  type = list(object({
    name   = string
    number = number
  }))
  default = []
}

locals {
  target_validation = var.target_organization ? 1 : 0 + length(var.target_folders) > 0 ? 1 : 0 + length(var.target_projects) > 0 ? 1 : 0
}

resource "null_resource" "validation" {
  count = local.target_validation > 1 ? 1 : 0
  provisioner "local-exec" {
    command = "echo 'Error: Only one of target_organization, target_folders, or target_projects can be used.' && exit 1"
  }
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