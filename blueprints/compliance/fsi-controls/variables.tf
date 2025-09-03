
variable "organization" {
  description = "Organization details."
  type = object({
    id          = number
    domain      = optional(string)
    customer_id = optional(string)
  })
}

variable "folder" {
  description = "The folder ID."
  type        = string
}

variable "logging_project" {
  description = "The logging project ID."
  type        = string
}

variable "security_project" {
  description = "The logging project ID."
  type        = string
}
variable "billing_project" {
  description = "The billing project ID."
  type        = string
}

variable "location" {
  description = "The location."
  type        = string
}

variable "prefix" {
  description = "Prefix used for organization policy constraint."
  type        = string
}

variable "billing_account" {
  description = "The billing account."
  type        = string
}
variable "notification_channel" {
  description = "The notification channel."
  type        = string
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
      # activity logs include Google Workspace / Cloud Identity logs
      # exclude them via additional filter stanza if needed
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
    iam = {
      filter = <<-FILTER
        protoPayload.serviceName="iamcredentials.googleapis.com" OR
        protoPayload.serviceName="iam.googleapis.com" OR
        protoPayload.serviceName="sts.googleapis.com"
      FILTER
    }
    vpc-sc = {
      filter = <<-FILTER
        protoPayload.metadata.@type="type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata"
      FILTER
    }
    workspace-audit-logs = {
      filter = <<-FILTER
        protoPayload.serviceName="admin.googleapis.com" OR
        protoPayload.serviceName="cloudidentity.googleapis.com" OR
        protoPayload.serviceName="login.googleapis.com"
      FILTER
    }
  }
}