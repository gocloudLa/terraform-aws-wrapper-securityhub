output "home_region" {
  description = "Home Region of the central configuration (provider Region)."
  value       = data.aws_region.current.region
}

output "finding_aggregator_arn" {
  description = "ARN of the finding aggregator."
  value       = aws_securityhub_finding_aggregator.this.arn
}

output "configuration_policy_ids" {
  description = "Map of configuration policy name to policy ID."
  value       = { for k, v in aws_securityhub_configuration_policy.this : k => v.id }
}

output "configuration_policy_arns" {
  description = "Map of configuration policy name to policy ARN."
  value       = { for k, v in aws_securityhub_configuration_policy.this : k => v.arn }
}
