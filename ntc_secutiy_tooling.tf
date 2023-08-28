# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # descriptive name of current AWS Organization to identify for which AWS Organization the security reports are generated
  org_name = "aws-c2"

  # get notified via sns topic about security hub findings
  securityhub_notifications_config = {
    enabled = true
    # only notify on finding with specific severity
    severity_labels = ["HIGH", "CRITICAL"]
    subscriptions = [
      {
        protocol  = "email"
        endpoints = ["stefano.franco@nuvibit.com"]
      }
    ]
  }

  # generate security hub reports and get notified via sns topic
  securityhub_reports_config = [
    {
      # choose from predefined security hub reports
      report = "securityhub-global-summary"
      # reports can be scheduled to be generated every x days
      schedule_in_days = 1
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

  securityhub_notifications_config = local.securityhub_notifications_config
  securityhub_reports_config       = local.securityhub_reports_config
  org_name                         = local.org_name

  providers = {
    aws = aws.euc1
  }
}