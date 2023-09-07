# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # enrich securityhub findings with account context
  securityhub_enrichment_settings = {
    enable_enrichment = true
    # to get alternate contact an assumable iam role is required in the org management account
    alternate_contact_assume_role = ""
  }

  # get notified via sns topic about security hub findings
  securityhub_notification_settings = {
    enable_notifications = false
    # identify for which AWS Organization notifications are sent
    org_identifier = "c2"
    # only notify on finding with specific severity
    severity_labels = ["CRITICAL"]
    subscriptions_findings_pretty = [
      {
        protocol  = "email"
        endpoints = ["stefano.franco@nuvibit.com"]
      }
    ]
    subscriptions_raw_findings = []
  }

  # generate security hub reports and get notified via sns topic
  securityhub_report_settings = [
    {
      # choose from predefined security hub reports
      report = "securityhub-summary"
      # reports can be scheduled to be generated every x days
      schedule_in_days = 7
      subscriptions = [
        {
          protocol  = "email"
          endpoints = ["stefano.franco@nuvibit.com"]
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

  securityhub_notification_settings = local.securityhub_notification_settings
  securityhub_report_settings       = local.securityhub_report_settings

  providers = {
    aws = aws.euc1
  }
}