provider "aws" {
  region = local.metadata.aws_region
}

provider "aws" {
  alias  = "org"
  region = local.metadata.aws_region
}

provider "aws" {
  alias  = "sec"
  region = local.metadata.aws_region
}

# Local multi-account testing: create a git-ignored providers_override.tf adding `profile` to each alias.
#
# Multi-account: point each alias to its account, e.g.
# provider "aws" {
#   alias  = "sec"
#   region = local.metadata.aws_region
#   assume_role { role_arn = "arn:aws:iam::<SEC_ACCOUNT_ID>:role/TerraformSecurity" }
# }
