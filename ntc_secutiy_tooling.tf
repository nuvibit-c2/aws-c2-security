# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # omit if you dont want to archive guardduty findings in s3
  guardduty_log_archive_bucket_arn  = local.ntc_parameters["log-archive"]["log_bucket_arns"]["guardduty"]
  guardduty_log_archive_kms_key_arn = local.ntc_parameters["log-archive"]["log_bucket_kms_key_arns"]["guardduty"]

  # sns topic subscriptions where ALL security events will be notified
  securityhub_sns_configuration = {
    subscriptions = [
      {
        protocol  = "email"
        endpoints = ["jonas.saegesser@nuvibit.com"]
      }
    ]
  }

  # sns topic subscriptions where summary report of security events will be notified
  securityhub_reports_configuration = [
    {
      report_name = "test-report"
      schedule    = "DAILY"
      subscriptions = [
        {
          protocol  = "email"
          endpoints = ["jonas.saegesser@nuvibit.com"]
        }
      ]
    }
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING
# ---------------------------------------------------------------------------------------------------------------------
module "security_tooling" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=beta"

  guardduty_log_archive_bucket_arn  = local.guardduty_log_archive_bucket_arn
  guardduty_log_archive_kms_key_arn = local.guardduty_log_archive_kms_key_arn
  securityhub_sns_configuration     = local.securityhub_sns_configuration
  securityhub_reports_configuration = local.securityhub_reports_configuration

  providers = {
    aws = aws.euc1
  }
}