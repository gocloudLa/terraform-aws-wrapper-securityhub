# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform Security Hub Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-securityhub/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-securityhub.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-securityhub.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-securityhub/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
Wrapper that turns on AWS Security Hub CSPM for a whole AWS Organization from the delegated administrator account,
using central configuration: a home-Region finding aggregator plus configuration policies that decide which
standards and controls run in each account, OU, or the entire organization, including accounts that join later.


### ✨ Features

- 🛡️ [Organization-wide central configuration](#organization-wide-central-configuration) - Switches the organization to CENTRAL configuration and enrolls every account through a root-associated policy.

- 📋 [Configuration policies per OU or account](#configuration-policies-per-ou-or-account) - Several policies with their own standards, control lists, and targets (root, OU IDs, account IDs).

- 🎛️ [Custom control parameters](#custom-control-parameters) - Tune controls that support parameters (password age, certificate expiry, authorized ports, …).

- 🌍 [Cross-Region aggregation](#cross-region-aggregation) - Optionally link other Regions to the home Region so policies and findings span them.




## 🚀 Quick Start
```hcl
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
```


## 🔧 Additional Features Usage

### Organization-wide central configuration
Creates `aws_securityhub_finding_aggregator` (home Region = `aws.sec` Region), then `aws_securityhub_organization_configuration`
with `configuration_type = "CENTRAL"`, `auto_enable = false` and `auto_enable_standards = "NONE"` as AWS requires.
With only `enable = true`, a `default` policy enabling FSBP and CIS AWS Foundations 3.0.0 is associated with the organization root.


<details><summary>Enable with the default policy</summary>

```hcl
securityhub_parameters = {
  enable = true
}
```


</details>


### Configuration policies per OU or account
Each entry of `configuration_policies` becomes an `aws_securityhub_configuration_policy`; each item of `associations` becomes an
`aws_securityhub_configuration_policy_association`. Standards accept short IDs (`<name>/v/<version>`) expanded to home-Region ARNs,
or full ARNs. Use either `disabled_control_identifiers` (deny-list) or `enabled_control_identifiers` (allow-list), not both.
`service_enabled = false` disables Security Hub CSPM on the associated targets.


<details><summary>Baseline for the org, Security Hub off for a sandbox OU</summary>

```hcl
securityhub_parameters = {
  enable = true

  configuration_policies = {
    "default" = {
      disabled_control_identifiers = ["Macie.1"] # Default: []
    }
    "sandbox-disabled" = {
      service_enabled = false
      associations    = ["ou-xxxx-xxxxxxxx"]
    }
  }
}
```


</details>


### Custom control parameters
`control_custom_parameters` is a map of control ID to a map of parameter name to `{ type, value, value_type }`.
`type` selects the typed block (`int`, `double`, `bool`, `string`, `enum`, `int_list`, `string_list`, `enum_list`); `value_type` defaults to `CUSTOM`.


<details><summary>Override IAM.7 and EC2.18 parameters</summary>

```hcl
securityhub_parameters = {
  enable = true

  configuration_policies = {
    "default" = {
      control_custom_parameters = {
        "IAM.7"  = { "MaxPasswordAge" = { type = "int", value = 90 } }
        "EC2.18" = { "authorizedTcpPorts" = { type = "int_list", value = [80, 443] } }
      }
    }
  }
}
```


</details>


### Cross-Region aggregation
Set `regions` (home Region plus linked Regions) and the wrapper derives `SPECIFIED_REGIONS` for the finding aggregator;
with only the home Region it uses `NO_REGIONS`. Linked Regions receive the same configuration policies,
so every linked Region also needs AWS Config recording and adds Security Hub cost.


<details><summary>Link two Regions</summary>

```hcl
securityhub_parameters = {
  enable = true

  regions = ["us-east-2", "us-east-1", "sa-east-1"] # Default: [<aws.sec provider Region>]
}
```


</details>




## 📑 Inputs
| Name                                                       | Description                                                                                                                                          | Type           | Default                                                                                               | Required |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------- | -------- |
| enable                                                     | When `true`, creates the finding aggregator, central configuration, policies, and associations (`count` gate).                                       | `bool`         | `false`                                                                                               | no       |
| regions                                                    | Home Region (aws.sec provider Region, must be included) plus Regions linked to central configuration; drives `finding_aggregator` unless overridden. | `list(string)` | `[<aws.sec Region>]`                                                                                  | no       |
| finding_aggregator.linking_mode                            | `linking_mode` on `aws_securityhub_finding_aggregator` (`ALL_REGIONS`, `ALL_REGIONS_EXCEPT_SPECIFIED`, `SPECIFIED_REGIONS`, `NO_REGIONS`).           | `string`       | `SPECIFIED_REGIONS` if `regions` has linked Regions, else `NO_REGIONS`                                | no       |
| finding_aggregator.specified_regions                       | Regions for the `*_SPECIFIED*` linking modes; must be empty otherwise.                                                                               | `list(string)` | `regions` minus home Region                                                                           | no       |
| management_account.enable                                  | Enable Security Hub CSPM in the management account (`aws.org`) in every Region in `regions`.                                                         | `bool`         | `true`                                                                                                | no       |
| configuration_policies                                     | Map of configuration policies keyed by policy name.                                                                                                  | `map(any)`     | `{ "default" = {} }`                                                                                  | no       |
| configuration_policies.<name>.description                  | `description` on `aws_securityhub_configuration_policy`.                                                                                             | `string`       | `"Managed by Terraform - GoCloud"`                                                                    | no       |
| configuration_policies.<name>.service_enabled              | Enables (`true`) or disables (`false`) Security Hub CSPM on associated targets.                                                                      | `bool`         | `true`                                                                                                | no       |
| configuration_policies.<name>.enabled_standards            | Standards to enable: short IDs (`<name>/v/<version>`) or full ARNs.                                                                                  | `list(string)` | `` `["aws-foundational-security-best-practices/v/1.0.0", "cis-aws-foundations-benchmark/v/3.0.0"]` `` | no       |
| configuration_policies.<name>.disabled_control_identifiers | Controls to disable (deny-list mode); all other controls stay enabled.                                                                               | `list(string)` | `[]`                                                                                                  | no       |
| configuration_policies.<name>.enabled_control_identifiers  | Controls to enable (allow-list mode); mutually exclusive with `disabled_control_identifiers`.                                                        | `list(string)` | `null`                                                                                                | no       |
| configuration_policies.<name>.control_custom_parameters    | Map of control ID → parameter name → `{ type, value, value_type }`.                                                                                  | `map(any)`     | `{}`                                                                                                  | no       |
| configuration_policies.<name>.associations                 | Targets: `"root"`, OU IDs, or account IDs.                                                                                                           | `list(string)` | `["root"]` for `default`, `[]` otherwise                                                              | no       |







## ⚠️ Important Notes
- ⚠️ **Delegated administrator prerequisite:** Register the Security Hub delegated administrator first with `terraform-aws-wrapper-service-delegation` (`security_hub = "<sec account id>"`), applied from the management account **in the intended home Region**. The management account cannot be the delegated administrator under central configuration.
- ℹ️ **Delegated administrator hub not managed:** Designating the delegated administrator enables Security Hub CSPM in that account automatically; the wrapper does not manage that hub (doing so would require an import in every deployment).
- ℹ️ **Management account:** Central configuration does not enable Security Hub in the management account, and its policy association fails until a hub exists there. The wrapper enables it from `aws.org` in every Region (`management_account.enable`); standards and controls then come from the associated configuration policy.
- ℹ️ **Security Hub CSPM vs. new Security Hub (v2):** This wrapper targets Security Hub CSPM. Organization enablement for the new Security Hub relies on AWS Organizations policies, and CSPM standards there are one-time "deployments" that are neither editable nor applied to new accounts; Terraform currently exposes only account/aggregator/feature resources for v2. Both services share the same delegated administrator, so adopting v2 later does not break this setup.
- ⚠️ **AWS Config required:** Most controls evaluate AWS Config rules; every account and Region covered by a policy needs a configuration recorder (see `terraform-aws-wrapper-config`), otherwise controls report `NO DATA`/failed.
- ℹ️ **Global resources:** Under central configuration, controls for global resources (e.g. IAM) are disabled automatically outside the home Region.
- ⚠️ **Destroy / delegated admin changes:** Changing or removing the delegated administrator through Organizations stops central configuration and deletes all configuration policies; accounts keep their last configuration. When tearing down, remove associations and policies first; destroying `aws_securityhub_organization_configuration` does not necessarily revert the organization to LOCAL configuration — verify the result in the console.
- ℹ️ **One policy per target:** A root, OU, or account can be directly associated with only one configuration policy; children inherit unless they have their own association.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 