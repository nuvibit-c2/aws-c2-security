# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # sns topic subscriptions where ALL security events will be notified
  securityhub_sns_configuration = {
    enabled = true
    # only send sns notifications for findings with specific severity
    severity_labels = ["HIGH", "CRITICAL"]
    subscriptions = [
      {
        protocol  = "email"
        endpoints = ["stefano.franco@nuvibit.com"]
      }
    ]
  }

  # sns topic subscriptions where summary report of security events will be notified
  securityhub_reports_configuration = [
    {
      # choose from predefined security hub reports
      report = "security-hub-org-summary"
      # reports can be scheduled to be generated "DAILY", "WEEKLY" or "MONTHLY"
      schedule = "DAILY"
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

  securityhub_sns_configuration     = local.securityhub_sns_configuration
  securityhub_reports_configuration = local.securityhub_reports_configuration

  providers = {
    aws = aws.euc1
  }
}