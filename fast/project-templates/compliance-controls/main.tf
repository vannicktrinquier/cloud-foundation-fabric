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
  }
}

module "organization" {
  source          = "../../../modules/organization"
  organization_id = "organizations/${var.organization.id}"
  factories_config = {
    org_policy_custom_constraints = "${var.controls_folder}/custom-constraints"
  }
}