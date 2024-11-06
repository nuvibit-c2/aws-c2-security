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
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling//modules/regional-security-config?ref=feat-regional-security-config"

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
      invite_members_by_acccount_id = []
    }
  }

  providers = {
    aws = aws.euc1
  }
}




# ---------------------------------------------------------------------------------------------------------------------
# ¦ DEBUG
# ---------------------------------------------------------------------------------------------------------------------
data "aws_guardduty_detector" "euc2" {
  provider = aws.euc2
}

locals {
  additional_configuration = [
    {
      name = "EKS_ADDON_MANAGEMENT",
      auto_enable = "ALL"
    },
    {
      name = "ECS_FARGATE_AGENT_MANAGEMENT",
      auto_enable = "ALL"
    },
    {
      name = "EC2_AGENT_MANAGEMENT",
      auto_enable = "ALL"
    }
  ]
}


# resource "aws_guardduty_detector_feature" "debug" {
#   detector_id = data.aws_guardduty_detector.euc2.id
#   name        = "RUNTIME_MONITORING"
#   status      = "ENABLED"

#   dynamic "additional_configuration" {
#     for_each = {
#       for configuration in local.additional_configuration : configuration.name => configuration
#     }
#     content {
#       name   = additional_configuration.value.name
#       status = additional_configuration.value.auto_enable == "NONE" ? "DISABLED" : "ENABLED"
#     }
#   }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "EKS_ADDON_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "EKS_ADDON_MANAGEMENT"
#   #     status = "ENABLED"
#   #   }
#   # }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "ECS_FARGATE_AGENT_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "ECS_FARGATE_AGENT_MANAGEMENT"
#   #     status = "ENABLED"
#   #   }
#   # }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "EC2_AGENT_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "EC2_AGENT_MANAGEMENT"
#   #     status = "ENABLED"
#   #   }
#   # }

#   provider = aws.euc2
# }


# resource "aws_guardduty_organization_configuration_feature" "debug" {
#   detector_id = data.aws_guardduty_detector.euc2.id
#   name        = "RUNTIME_MONITORING"
#   auto_enable = "NEW"

#   dynamic "additional_configuration" {
#     for_each = {
#       for configuration in local.additional_configuration : configuration.name => configuration
#     }
#     content {
#       name   = additional_configuration.value.name
#       auto_enable = additional_configuration.value.auto_enable
#     }
#   }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "ECS_FARGATE_AGENT_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "ECS_FARGATE_AGENT_MANAGEMENT"
#   #     auto_enable = "NEW"
#   #   }
#   # }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "EC2_AGENT_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "EC2_AGENT_MANAGEMENT"
#   #     auto_enable = "NEW"
#   #   }
#   # }

#   # dynamic "additional_configuration" {
#   #   for_each = contains(local.features[*].name, "EKS_ADDON_MANAGEMENT") ? ["true"] : []
#   #   content {
#   #     name   = "EKS_ADDON_MANAGEMENT"
#   #     auto_enable = "NEW"
#   #   }
#   # }

#   provider = aws.euc2
# }