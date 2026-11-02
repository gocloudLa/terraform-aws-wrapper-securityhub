module "wrapper_securityhub" {
  source = "../../"

  providers = {
    aws.org = aws.org # Organization Management Account
    aws.sec = aws.sec # Security Tooling Account ( Security Hub delegated administrator )
  }

  metadata = local.metadata

  securityhub_parameters = {
    enable = true

    # -------------------------------------------------------------------------
    # regions — home Region (aws.sec provider Region) + linked Regions.
    # -------------------------------------------------------------------------
    regions = ["us-east-2", "us-east-1"] # Default: [<aws.sec provider Region>]

    # -------------------------------------------------------------------------
    # finding_aggregator — derived from regions; set only to override.
    # -------------------------------------------------------------------------
    finding_aggregator = {
      # linking_mode      = null # derived: SPECIFIED_REGIONS when regions has linked Regions, else NO_REGIONS
      # specified_regions = null # derived: regions minus the home Region
    }

    # -------------------------------------------------------------------------
    # configuration_policies — omit the key to get a single "default" policy
    # (FSBP + CIS 3.0.0) associated with the organization root.
    # -------------------------------------------------------------------------
    configuration_policies = {
      "default" = {
        # description                  = "Managed by Terraform - GoCloud"
        # service_enabled              = true
        # enabled_standards            = ["aws-foundational-security-best-practices/v/1.0.0", "cis-aws-foundations-benchmark/v/3.0.0"]
        # disabled_control_identifiers = []
        # enabled_control_identifiers  = null # set to switch to allow-list mode (mutually exclusive with disabled list)
        # associations                 = ["root"] # "root", OU IDs (ou-…) or account IDs

        enabled_standards = [ # Default: FSBP + CIS 3.0.0
          "aws-foundational-security-best-practices/v/1.0.0",
          "cis-aws-foundations-benchmark/v/3.0.0",
          "nist-800-53/v/5.0.0",
        ]
        disabled_control_identifiers = ["Macie.1"] # Default: []

        control_custom_parameters = { # Default: {}
          "IAM.7" = {
            "MaxPasswordAge" = { type = "int", value = 90 }
          }
        }
      }

      # "sandbox-disabled" = {
      #   service_enabled = false
      #   associations    = ["ou-xxxx-xxxxxxxx"]
      # }
    }
  }

  securityhub_defaults = {}
}
