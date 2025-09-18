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

module "controls-folder" {
  for_each      = { for f in var.target_folders : f => f }
  source        = "../../../modules/folder"
  folder_create = false

  id   = "folders/${each.key}"
  name = each.key

  factories_config = {
    org_policies            = "${var.controls_folder}/org-policies"
    scc_customs_sha_modules = "${var.controls_folder}/scc-custom-sha-modules"
  }

  context = {
    condition_vars = local.ctx_condition_vars
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

  depends_on = [module.organization]
}
