# locals {
#   custom_constraint_names = toset([
#     "custom.cloudrunJobRequireBinaryAuthorization",
#     "custom.cloudrunServiceRequireBinaryAuthorization"
#   ])
#     org_id = "262782368104"
# }

# import {
#   for_each = local.custom_constraint_names
#   id = "organizations/${local.org_id}/customConstraints/${each.key}"
#   to = module.organization.google_org_policy_custom_constraint.constraint[each.key]
# }