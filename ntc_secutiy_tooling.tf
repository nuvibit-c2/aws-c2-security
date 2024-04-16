# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING
# ---------------------------------------------------------------------------------------------------------------------
module "security_tooling" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=1.1.2"

  # enrich securityhub findings with account context
  securityhub_enrichment_settings = {
    enable_enrichment = true
    # enrich only findings of specific severity from ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    severity_labels = ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    # to get alternate contact an assumable iam role is required in the org management account
    alternate_contact_assume_role = "ntc-org-account-reader"
  }

  # get notified via sns topic about security hub findings
  securityhub_notification_settings = {
    enable_notifications = true
    # identify for which AWS Organization notifications are sent
    org_identifier = "c2"
    # prettified finding notifications for specific severities
    severity_labels_findings_pretty = ["CRITICAL"]
    # TODO: if product not defined go to fallback
    severity_labels_by_product_findings_pretty = [
      {
        product  = "security_hub"
        severity = ["CRITICAL"]
      },
      {
        product  = "guard_duty"
        severity = ["HIGH"]
      }
    ]
    subscriptions_findings_pretty = [
      # {
      #   protocol  = "email"
      #   endpoints = ["stefano.franco@nuvibit.com"]
      # }
    ]
    # raw json notifications for specific severities
    severity_labels_findings_raw = ["CRITICAL"]
    subscriptions_raw_findings   = []
    # define how frequent reminders for findings should be sent
    reminder_x_days_unresolved_by_severity = {
      # TODO: add option to disable reminders? e.g. null
      critical      = 1
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

  securityhub_processing_settings = {
    enable_processing = true
    # uses the security hub automation rules and asff syntax
    # https://docs.aws.amazon.com/securityhub/latest/userguide/automation-rules.html#automation-rules-criteria-actions
    # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format-syntax.html
    automation_rules = jsondecode(file("${path.module}/example_automation_rules.json"))
  }

  providers = {
    aws = aws.euc1
  }
}