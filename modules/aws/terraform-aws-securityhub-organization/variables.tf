variable "home_region" {
  type        = string
  description = "Central configuration home Region (aws.sec provider Region)."
}

variable "regions" {
  type        = list(string)
  description = "Regions requested for Security Hub CSPM; must include the home Region."
}

variable "linking_mode" {
  type        = string
  description = "Finding aggregator linking mode (ALL_REGIONS, ALL_REGIONS_EXCEPT_SPECIFIED, SPECIFIED_REGIONS, NO_REGIONS)."
  default     = "NO_REGIONS"

  validation {
    condition     = contains(["ALL_REGIONS", "ALL_REGIONS_EXCEPT_SPECIFIED", "SPECIFIED_REGIONS", "NO_REGIONS"], var.linking_mode)
    error_message = "linking_mode must be one of ALL_REGIONS, ALL_REGIONS_EXCEPT_SPECIFIED, SPECIFIED_REGIONS, NO_REGIONS."
  }
}

variable "specified_regions" {
  type        = list(string)
  description = "Regions used by *_SPECIFIED linking modes."
  default     = []
}

variable "enable_management_account" {
  type        = bool
  description = "Enable Security Hub in the organization management account (aws.org) in every Region."
  default     = true
}

variable "configuration_policies" {
  type        = any
  description = "Map of normalized configuration policies keyed by policy name (see wrapper locals.tf)."
  default     = {}
}

variable "configuration_policy_associations" {
  type = map(object({
    policy_name = string
    target_id   = string
  }))
  description = "Map of policy associations keyed by \"<policy_name>-<target>\"."
  default     = {}
}
