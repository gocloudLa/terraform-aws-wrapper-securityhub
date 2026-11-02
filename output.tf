output "enabled" {
  description = "Whether Security Hub resources were created (securityhub_parameters.enable)."
  value       = local.securityhub_enable == 1
}

output "home_region" {
  description = "Security Hub central configuration home Region (aws.sec provider Region)."
  value       = try(module.organization[0].home_region, null)
}

output "finding_aggregator_arn" {
  description = "ARN of the Security Hub finding aggregator in the home Region."
  value       = try(module.organization[0].finding_aggregator_arn, null)
}

output "configuration_policy_ids" {
  description = "Map of configuration policy name to policy ID."
  value       = try(module.organization[0].configuration_policy_ids, null)
}

output "configuration_policy_arns" {
  description = "Map of configuration policy name to policy ARN."
  value       = try(module.organization[0].configuration_policy_arns, null)
}
