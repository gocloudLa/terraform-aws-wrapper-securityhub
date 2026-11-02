# Complete example 🚀

Runnable root module wiring for terraform-aws-wrapper-securityhub; parameters follow the same variable pattern as other GoCloud wrappers (metadata, securityhub_parameters, securityhub_defaults).

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
Demonstrate Security Hub CSPM central configuration from the delegated administrator account with a root-associated configuration policy, extra standard, disabled control, and a custom control parameter.

#### Key Features Demonstrated
- **metadata** — Defined in `metadata.tf` (same pattern as other examples; optional `variable "metadata"` remains commented in `variables.tf`).
- **securityhub_parameters** — Inline map in `main.tf`; commented lines show wrapper defaults, uncommented overrides carry `# Default: …`.
- **securityhub_defaults** — Fallback for policy fields omitted in each `configuration_policies` entry.
- **Providers** — `aws.org` (management, read-only org lookup) and `aws.sec` (delegated administrator); add `profile`/`assume_role` per alias for multi-account runs (git-ignored `providers_override.tf`).

## 🚀 Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## 🔒 Security Notes

⚠️ **Production Considerations**: 
- This example may include configurations that are not suitable for production environments
- Review and customize security settings, access controls, and resource configurations
- Ensure compliance with your organization's security policies
- Consider implementing proper monitoring, logging, and backup strategies

## 📖 Documentation

For detailed module documentation and additional examples, see the main [README.md](../../README.md) file. 