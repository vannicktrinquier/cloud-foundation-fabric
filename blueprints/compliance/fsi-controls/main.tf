module "organization" {
  source          = "../../../modules/organization"
  organization_id = "organizations/${var.organization.id}"

  factories_config = {
    org_policy_custom_constraints = "data/custom-constraints"
    scc_custom_modules            = "data/scc-custom-modules"

    context = {
      org_policies = {
        organization = var.organization
      }
      org_policy_custom_constraints = {}
      monitoring_alerts             = {}
    }
  }

  logging_sinks = merge({
    for name, attrs in var.log_sinks : name => {
      destination = var.logging_project
      filter      = attrs.filter
      type        = "project"
      disabled    = attrs.disabled
      exclusions  = attrs.exclusions
    }
    },
  )
}

module "folder" {
  source = "../../../modules/folder"
  parent = "organizations/${var.organization.id}"

  name = "FSI Foundation"
  factories_config = {
    org_policies = "data/org-policies"

    context = {
      org_policies = {
        organization = var.organization
        crypto = {
          project_1 = var.security_project
        }
        vpn = {
          peer_ip_1 = "1.1.1.1"
        }
        nat = {
          project_1 = "dbs-validator-kcc-29ae"
        }
      }
    }
  }
}