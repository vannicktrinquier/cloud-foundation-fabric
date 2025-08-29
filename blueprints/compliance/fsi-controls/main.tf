module "organization" {
  source          = "../../../modules/organization"
  organization_id = "organizations/${var.organization.id}"

  factories_config = {
    # org_policies                  = "data/org-policies"
    org_policy_custom_constraints = "data/custom-constraints"
    scc_custom_modules            = "data/scc-custom-modules"
    monitoring_alerts             = "data/monitoring-alerts"

    context = {
      org_policies = {
        organization = var.organization
      }
      org_policy_custom_constraints = {
        prefix = var.prefix
      }
      monitoring_alerts = {
        project              = var.monitoring_project
        notification_channel = var.notification_channel
      }
    }
  }
}


module "folder" {
  source = "../../../modules/folder"
  parent = "folders/${var.folder}"

  name = "FSI Foundation"

  factories_config = {
    org_policies = "data/org-policies"

    context = {
      org_policies = {
        organization = var.organization
        crypto = {
          project_1 = "dbs-validator-kcc-29ae"
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