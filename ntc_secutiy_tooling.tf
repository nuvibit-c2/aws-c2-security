# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # enrich securityhub findings with account context
  securityhub_enrichment_settings = {
    enable_enrichment = true
    # enrich only findings of specific severity from ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    severity_labels = ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    # to get alternate contact an assumable iam role is required in the org management account
    alternate_contact_assume_role = ""
  }

  # get notified via sns topic about security hub findings
  securityhub_notification_settings = {
    enable_notifications = true
    # identify for which AWS Organization notifications are sent
    org_identifier = "c2"
    # prettified finding notifications for specific severities
    severity_labels_findings_pretty = ["CRITICAL"]
    subscriptions_findings_pretty = [
      {
        protocol  = "email"
        endpoints = ["stefano.franco@nuvibit.com"]
      }
    ]
    # raw json notifications for specific severities
    severity_labels_findings_raw = ["HIGH", "CRITICAL"]
    subscriptions_raw_findings   = []
    # define how frequent reminders for findings should be sent
    reminder_x_days_unresolved_by_severity = {
      critical      = 3 # default is 1
      high          = 3
      medium        = 7
      low           = 14
      informational = 14
    }
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
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=1.0.0"

  securityhub_enrichment_settings   = local.securityhub_enrichment_settings
  securityhub_notification_settings = local.securityhub_notification_settings
  securityhub_report_settings       = local.securityhub_report_settings

  providers = {
    aws = aws.euc1
  }
}