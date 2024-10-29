# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING
# ---------------------------------------------------------------------------------------------------------------------
module "ntc_security_tooling" {
  # source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=1.2.0"
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=feat-regional-security-config"

  # aggregate config data from all accounts in all regions across organizations
  # admin delegation for "config.amazonaws.com" required
  # https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html
  enable_config_aggregation = true

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

  # securityhub aggregration is required for central configuration
  enable_securityhub_central_configuration = true
  enable_securityhub_aggregation           = true
  # can be either "ALL_REGIONS" or a list of regions which should be aggregated
  securityhub_aggregation_regions = ["ALL_REGIONS"]

  # define securityhub central configuration policies
  # https://docs.aws.amazon.com/securityhub/latest/userguide/central-configuration-intro.html
  securityhub_central_configuration_polices = [
    {
      name        = "ntc-securityhub-central-policy"
      description = "securityhub central policy"
      # enable or disable securityhub in target accounts
      enable_securityhub = true
      # policy targets can either be organizational units (OU) or aws accounts (ID)
      policy_targets = [
        local.ntc_parameters["mgmt-account-factory"]["core_accounts"]["aws-c2-management"],
        local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/infrastructure"],
        local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/security"],
        local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/workloads"],
        # policy will not be rolled out to sandbox accounts and to suspended or decommissioned accounts
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/sandbox"],
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/suspended"],
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/decommission"],
        # to apply policy to all accounts in organization use /root parent ou as target
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root"]
      ]
      enabled_standards = [
        "aws-foundational-security-best-practices/v/1.0.0",
        "cis-aws-foundations-benchmark/v/1.2.0",
        # "cis-aws-foundations-benchmark/v/1.4.0",
        # "nist-800-53/v/5.0.0",
        # "pci-dss/v/3.2.1",
      ]
      # either provide a list of control ids which should be enabled (all other existing and future controls will be disabled)
      enabled_control_ids = []
      # or a list of control ids which should be disabled (all other existing and future controls will be enabled)
      # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-controls-reference.html
      disabled_control_ids = [
        "IAM.9",    # "MFA should be enabled for the root user"
        "IAM.18",   # "Ensure a support role has been created to manage incidents with AWS Support"
        "Config.1", # "AWS Config should be enabled"
        "EC2.10",   # "Security groups should not allow ingress from 0.0.0.0/0 or ::/0 to port 22"
        "IAM.6",    # "Hardware MFA should be enabled for the root user"
        "S3.1"      # "S3 general purpose buckets should have block public access settings enabled"
      ]
      # some controls allow to customize parameters
      # https://docs.aws.amazon.com/securityhub/latest/userguide/custom-control-parameters.html
      # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-controls-reference.html
      customized_security_controls = [
        {
          control_id = "IAM.7"
          parameters = [
            {
              name  = "MaxPasswordAge"
              value = 60
              type  = "Integer"
            },
            {
              name  = "RequireNumbers"
              value = false
              type  = "Boolean"
            }
          ]
        }
      ]
    }
  ]

  providers = {
    # WARNING some features of security tooling cannot be provisioned in an opt-in region
    # e.g security hub aggregation does not supported an opt-in region as main region
    # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-regions.html
    aws = aws.euc1
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING - REGIONAL CONFIG
# ---------------------------------------------------------------------------------------------------------------------
module "ntc_regional_security_config_euc1" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling//modules/regional-security-config?ref=feat-regional-security-config"

  # https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_regions.html
  guardduty_config = {
    enabled                      = true
    finding_publishing_frequency = "SIX_HOURS"

    # WARNING: requires admin delegation of 'guardduty.amazonaws.com'
    organization_config = {
      # enable guardduty in organization for 'ALL', 'NEW' or 'NONE'
      auto_enable = "ALL"
      # individual features can be enabled in organization for 'ALL', 'NEW' or 'NONE'
      # enabled features will also be configured for current account
      features = [
        {
          auto_enable = "ALL"
          name        = "S3_DATA_EVENTS"
        },
        {
          auto_enable = "ALL"
          name        = "EBS_MALWARE_PROTECTION"
        },
        {
          auto_enable = "ALL"
          name        = "RDS_LOGIN_EVENTS"
        },
        {
          auto_enable = "ALL"
          name        = "LAMBDA_NETWORK_LOGS"
        },
        {
          auto_enable = "NONE"
          name        = "EKS_AUDIT_LOGS"
        },
        {
          auto_enable = "ALL"
          name        = "RUNTIME_MONITORING"
          # 'RUNTIME_MONITORING' has additional configurations
          additional_configuration = [
            {
              auto_enable = "NONE"
              name        = "EKS_ADDON_MANAGEMENT"
            },
            {
              auto_enable = "ALL"
              name        = "ECS_FARGATE_AGENT_MANAGEMENT"
            },
            {
              auto_enable = "ALL"
              name        = "EC2_AGENT_MANAGEMENT"
            }
          ]
        }
      ]
      # (optional) invite existing organization members to guardduty
      invite_members_by_acccount_id = []
    }

    # (optional) export all guardduty findings to s3 log archive
    export_findings         = true
    log_archive_bucket_arn  = local.ntc_parameters["log-archive"]["log_bucket_arns"]["guardduty"]
    log_archive_kms_key_arn = local.ntc_parameters["log-archive"]["log_bucket_kms_key_arns"]["guardduty"]
  }

  # https://docs.aws.amazon.com/inspector/latest/user/inspector_regions.html
  inspector_config = {
    enabled = true

    # WARNING: requires admin delegation of 'inspector2.amazonaws.com'
    organization_config = {
      auto_enable = true
      # individual features can be enabled in organization for 'NEW' or 'NONE'
      # WARNING: features cannot be enabled for 'ALL' members (inspector limitation)
      # enabled features will also be configured for current account
      features = [
        {
          auto_enable = "NEW"
          name        = "EC2"
        },
        {
          auto_enable = "NEW"
          name        = "ECR"
        },
        {
          auto_enable = "NEW"
          name        = "LAMBDA"
        },
        {
          auto_enable = "NEW"
          name        = "LAMBDA_CODE"
        }
      ]
      # (optional) invite existing organization members to inspector
      invite_members_by_acccount_id = []
    }
  }

  providers = {
    aws = aws.euc1
  }
}