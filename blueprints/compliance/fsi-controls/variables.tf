variable "organization_id" {
  description = "The organization ID."
  type        = string
}

variable "organization" {
  description = "Organization details."
  type = object({
    id          = number
    domain      = optional(string)
    customer_id = optional(string)
  })
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