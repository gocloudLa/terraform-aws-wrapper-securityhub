output "enabled" {
  description = "Whether the wrapper created Security Hub resources."
  value       = module.wrapper_securityhub.enabled
}

output "home_region" {
  value = module.wrapper_securityhub.home_region
}

output "finding_aggregator_arn" {
  value = module.wrapper_securityhub.finding_aggregator_arn
}

output "configuration_policy_ids" {
  value = module.wrapper_securityhub.configuration_policy_ids
}

output "configuration_policy_arns" {
  value = module.wrapper_securityhub.configuration_policy_arns
}
