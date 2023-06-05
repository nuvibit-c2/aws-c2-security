# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING
# ---------------------------------------------------------------------------------------------------------------------
module "security_tooling" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=beta"

  guardduty_log_archive_bucket_arn = local.ntc_parameters.log-archive.log_bucket_arns.guardduty
  guardduty_log_archive_kms_key_arn = local.ntc_parameters.log-archive.log_bucket_kms_key_arns.guardduty

  securityhub_sns_configuration = {
    subscriptions = [
      {
        protocol = "email"
        endpoints = ["jonas.saegesser@nuvibit.com"]
      }
    ]
  }

  securityhub_reports_configuration = [
    {
      report_name = "test-report"
      schedule = "WEEKLY"
      subscriptions = [
        {
          protocol = "email"
          endpoints = ["jonas.saegesser@nuvibit.com"]
        }
      ]
    }
  ]
}

resource "aws_securityhub_organization_configuration" "ntc_securityhub_org_config" {
  auto_enable = true
  provider = aws.use1
}
