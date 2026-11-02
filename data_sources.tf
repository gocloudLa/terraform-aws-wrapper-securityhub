data "aws_partition" "sec" {
  provider = aws.sec
}

data "aws_region" "sec" {
  provider = aws.sec
}

data "aws_organizations_organization" "this" {
  count    = local.securityhub_enable
  provider = aws.org
}
