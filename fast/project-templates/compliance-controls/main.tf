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


locals {
  ctx_condition_vars = {
    organization = {
      id          = var.organization.id
      customer_id = var.organization.customer_id
      domain      = var.organization.domain
    }
    crypto = {
      project_1 = var.security_project.name
    }
    vpn = {
      peer_ip_1 = "1.1.1.1"
    }
    nat = {
      project_1 = "dbs-validator-kcc-29ae"
    }
  }
}

module "organization" {
  source          = "../../../modules/organization"
  organization_id = "organizations/${var.organization.id}"

  factories_config = {
    org_policy_custom_constraints = "data/custom-constraints"
    scc_custom_modules            = "data/scc-custom-modules"
  }

  context = {
    condition_vars = local.ctx_condition_vars
  }

  scc_custom_modules = {
    kmsKeyRotationPeriod = {
      description    = "The rotation period of the identified cryptokey resource exceeds 30 days."
      recommendation = "Set the rotation period to at most 30 days."
      severity       = "MEDIUM"
      predicate = {
        expression = "resource.rotationPeriod > duration(\"2592000s\")"
      }
      resource_selector = {
        resource_types = ["cloudkms.googleapis.com/CryptoKey"]
      }
    }
  }

  logging_sinks = merge({
    for name, attrs in var.log_sinks : name => {
      destination = module.logging-project.project_id
      filter      = attrs.filter
      type        = "project"
      disabled    = attrs.disabled
      exclusions  = attrs.exclusions
    }
  }, )
}

module "folder" {
  source = "../../../modules/folder"
  parent = "organizations/${var.organization.id}"

  name = "FSI Foundation"
  factories_config = {
    org_policies       = "data/org-policies"
    scc_custom_modules = "data/scc-custom-modules"
  }

  context = {
    condition_vars = local.ctx_condition_vars
  }
}