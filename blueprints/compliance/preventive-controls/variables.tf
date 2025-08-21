variable "organization_id" {
  description = "The organization ID."
}

variable "prefix" {
  description = "Prefix used for organization policy constraint."
  type        = string
}

variable "project" {
  description = "The project ID."
  type        = string
}

variable "billing_project" {
  description = "The billing project ID."
  type        = string
}