data "aws_region" "current" {}

# The management account is not covered by central configuration until Security Hub is enabled in it.
# Standards and controls come from the configuration policy associated with it (root by default).
# Key: Region.
resource "aws_securityhub_account" "management" {
  for_each = var.enable_management_account ? toset(var.regions) : toset([])
  provider = aws.org

  region = each.key

  enable_default_standards = false
}

resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode      = var.linking_mode
  specified_regions = strcontains(var.linking_mode, "SPECIFIED") ? var.specified_regions : null

  lifecycle {
    precondition {
      condition     = strcontains(var.linking_mode, "SPECIFIED") == (length(var.specified_regions) > 0)
      error_message = "specified_regions must be set when linking_mode is *_SPECIFIED* and empty otherwise."
    }
    precondition {
      condition     = contains(var.regions, var.home_region)
      error_message = "regions must include the home Region (aws.sec provider Region)."
    }
  }
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = false
  auto_enable_standards = "NONE"

  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.this]
}

# Key: policy name.
resource "aws_securityhub_configuration_policy" "this" {
  for_each = var.configuration_policies

  name        = each.key
  description = each.value.description

  configuration_policy {
    service_enabled       = each.value.service_enabled
    enabled_standard_arns = each.value.service_enabled ? each.value.enabled_standard_arns : null

    dynamic "security_controls_configuration" {
      for_each = each.value.service_enabled ? [1] : []
      content {
        disabled_control_identifiers = each.value.enabled_control_identifiers == null ? each.value.disabled_control_identifiers : null
        enabled_control_identifiers  = each.value.enabled_control_identifiers

        dynamic "security_control_custom_parameter" {
          for_each = each.value.control_custom_parameters
          iterator = control
          content {
            security_control_id = control.value.security_control_id

            dynamic "parameter" {
              for_each = control.value.parameters
              iterator = param
              content {
                name       = param.value.name
                value_type = param.value.value_type

                dynamic "bool" {
                  for_each = param.value.type == "bool" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "double" {
                  for_each = param.value.type == "double" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "enum" {
                  for_each = param.value.type == "enum" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "enum_list" {
                  for_each = param.value.type == "enum_list" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "int" {
                  for_each = param.value.type == "int" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "int_list" {
                  for_each = param.value.type == "int_list" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "string" {
                  for_each = param.value.type == "string" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }

                dynamic "string_list" {
                  for_each = param.value.type == "string_list" ? [param.value.value] : []
                  iterator = v
                  content {
                    value = v.value
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !(each.value.enabled_control_identifiers != null && length(each.value.disabled_control_identifiers) > 0)
      error_message = "Set either enabled_control_identifiers or disabled_control_identifiers, not both."
    }
  }

  depends_on = [aws_securityhub_organization_configuration.this]
}

# Key: "<policy_name>-<target>" (target = root, OU ID, or account ID).
resource "aws_securityhub_configuration_policy_association" "this" {
  for_each = var.configuration_policy_associations

  policy_id = aws_securityhub_configuration_policy.this[each.value.policy_name].id
  target_id = each.value.target_id

  # An association that reaches the management account before its hub exists stays FAILED for that account.
  depends_on = [aws_securityhub_account.management]
}
