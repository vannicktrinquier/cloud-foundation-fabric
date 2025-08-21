module "organization" {
  source          = "../../../modules/organization"
  organization_id = "organizations/${var.organization_id}"

  factories_config = {
    org_policies                  = "data/org-policies"
    org_policy_custom_constraints = "data/custom-constraints"

    context = {
      org_policy_custom_constraints = {
        prefix = var.prefix
      }
    }
  }
}