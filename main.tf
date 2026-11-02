module "organization" {
  source = "./modules/aws/terraform-aws-securityhub-organization"
  count  = local.securityhub_enable

  providers = {
    aws     = aws.sec
    aws.org = aws.org
  }

  home_region       = local.home_region
  regions           = local.regions
  linking_mode      = local.linking_mode
  specified_regions = local.specified_regions

  enable_management_account = try(var.securityhub_parameters.management_account.enable, var.securityhub_defaults.management_account.enable, true)

  configuration_policies            = local.configuration_policies
  configuration_policy_associations = local.configuration_policy_associations
}
