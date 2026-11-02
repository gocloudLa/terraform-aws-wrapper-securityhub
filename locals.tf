locals {
  securityhub_enable = try(var.securityhub_parameters.enable, false) ? 1 : 0

  organization_root_id = local.securityhub_enable == 1 ? data.aws_organizations_organization.this[0].roots[0].id : null

  # Home Region = aws.sec provider Region. `regions` (same key as the other security wrappers) links every other
  # listed Region to it; an explicit finding_aggregator.linking_mode / specified_regions takes precedence.
  home_region    = data.aws_region.sec.region
  regions        = try(var.securityhub_parameters.regions, [local.home_region])
  linked_regions = sort(tolist(setsubtract(toset(local.regions), [local.home_region])))

  linking_mode      = try(var.securityhub_parameters.finding_aggregator.linking_mode, length(local.linked_regions) > 0 ? "SPECIFIED_REGIONS" : "NO_REGIONS")
  specified_regions = try(var.securityhub_parameters.finding_aggregator.specified_regions, local.linking_mode == "SPECIFIED_REGIONS" ? local.linked_regions : [])

  default_enabled_standards = [
    "aws-foundational-security-best-practices/v/1.0.0",
    "cis-aws-foundations-benchmark/v/3.0.0",
  ]

  # Configuration policies normalized for the child module. Key: policy name (as written in configuration_policies).
  configuration_policies = {
    for k, v in try(var.securityhub_parameters.configuration_policies, { "default" = {} }) :
    k => {
      description     = try(v.description, var.securityhub_defaults.description, "Managed by Terraform - GoCloud")
      service_enabled = try(v.service_enabled, var.securityhub_defaults.service_enabled, true)

      # Short standard ids ("<name>/v/<version>") expand to home-Region standard ARNs; full ARNs pass through.
      enabled_standard_arns = [
        for s in try(v.enabled_standards, var.securityhub_defaults.enabled_standards, local.default_enabled_standards) :
        startswith(s, "arn:") ? s : "arn:${data.aws_partition.sec.partition}:securityhub:${data.aws_region.sec.region}::standards/${s}"
      ]

      disabled_control_identifiers = try(v.disabled_control_identifiers, var.securityhub_defaults.disabled_control_identifiers, [])
      enabled_control_identifiers  = try(v.enabled_control_identifiers, var.securityhub_defaults.enabled_control_identifiers, null)

      control_custom_parameters = [
        for control_id, params in try(v.control_custom_parameters, var.securityhub_defaults.control_custom_parameters, {}) : {
          security_control_id = control_id
          parameters = [
            for name, p in params : {
              name       = name
              value_type = try(p.value_type, "CUSTOM")
              type       = try(p.type, null)
              value      = try(p.value, null)
            }
          ]
        }
      ]

      associations = try(v.associations, k == "default" ? ["root"] : [])
    }
  }

  # Policy -> target associations. Key: "<policy_name>-<target>" with target as written ("root", "ou-…", account id).
  configuration_policy_associations_tmp = [
    for k, v in local.configuration_policies :
    [
      for t in v.associations :
      {
        "${k}-${t}" = {
          policy_name = k
          target_id   = t == "root" ? local.organization_root_id : t
        }
      }
    ]
  ]

  configuration_policy_associations = merge(flatten(local.configuration_policy_associations_tmp)...)
}

# output "configuration_policy_associations" {
#   value = local.configuration_policy_associations
# }
