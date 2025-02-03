# WARNING: guardduty will get enabled by default when creating the admin delegation in organizations
# this will cause an error when configuring regional security config for guardduty
# to avoid this issue guardduty detector can be imported

data "aws_guardduty_detector" "euc1" {
  provider = aws.euc1
}
import {
  to = module.ntc_regional_security_config_euc1.aws_guardduty_detector.ntc_guardduty[0]
  id = data.aws_guardduty_detector.euc1.id
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC SECURITY TOOLING - REGIONAL CONFIGURATION - FRANKFURT
# ---------------------------------------------------------------------------------------------------------------------
module "ntc_regional_security_config_euc1" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling//modules/regional-security-config?ref=1.6.0"

  # https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_regions.html
  guardduty_config = {
    enabled                      = true
    finding_publishing_frequency = "SIX_HOURS"

    # WARNING: requires admin delegation of 'guardduty.amazonaws.com'
    organization_config = {
      # enable guardduty in organization for 'ALL' members, 'NEW' members or 'NONE'
      auto_enable = "ALL"
      # individual features can be enabled in organization for 'ALL' members, 'NEW' members or 'NONE'
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
      invite_members_by_account_id = []
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
      # individual features can be enabled in organization for 'NEW' members or 'NONE'
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
      invite_members_by_account_id = []
    }
  }

  # iam access analyzer helps you identify the resources in your organization and accounts, such as Amazon S3 buckets or IAM roles, shared with an external entity
  iam_access_analyzer_config = [
    {
      analyzer_name = "ntc-external-access-analysis"
      # external access analyzers help identify resources in your organization and accounts that are shared with an external entity
      findings_type = "external_access_analysis"
      # scope of analyzer can be current account or the entire organization 
      findings_scope = "organization"
      rules = [
        {
          rule_name = "archive-all-not-public"
          filters = [
            {
              # the filter keys for IAM Access Analyzer can be found here:
              # https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-filter-keys.html
              filter_key = "isPublic"
              # valid conditions are 'equals', 'not_equals', 'contains' and 'exists'
              condition = "equals"
              values    = ["false"]
            }
          ]
        },
        {
          rule_name = "archive-all-ntc-userids"
          filters = [
            {
              filter_key = "error"
              condition  = "exists"
              values     = ["true"]
            },
            {
              filter_key = "condition.aws:UserId"
              condition  = "contains"
              values     = ["AIDACKCEVSQ6C2EXAMPLE"]
            }
          ]
        }
      ]
    },
    # WARNING: unused access analyzer should only be enabled in a single region
    # findings for the unused access analyzer do not change based on region
    {
      analyzer_name = "ntc-unused-access-analysis"
      # unused access analyzers help identify unused access in your organization and accounts
      findings_type = "unused_access_analysis"
      # scope of analyzer can be current account or the entire organization 
      findings_scope = "organization"
      # access age in days for which to generate findings for unused access
      unused_access_age = 90
      rules = [
        {
          rule_name = "archive-all-aws-sso-roles"
          filters = [
            {
              filter_key = "resource"
              condition  = "contains"
              values     = ["aws-reserved/sso.amazonaws.com/"]
            }
          ]
        }
      ]
    }
  ]

  providers = {
    aws = aws.euc1
  }
}