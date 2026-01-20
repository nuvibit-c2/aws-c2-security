# =====================================================================================================================
# STATE MIGRATIONS - v1.x to v2.x
# =====================================================================================================================
# These moved blocks ensure Terraform state is updated without recreating resources
# Run: terraform plan - should show only "moved" operations (no creates/destroys)
# After successful migration, this file can be deleted

# -------------------------------------------------------------------------------------------------------------------
# GUARDDUTY - FRANKFURT (eu-central-1)
# -------------------------------------------------------------------------------------------------------------------
moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector.ntc_guardduty[0]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector.ntc_guardduty[0]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["EBS_MALWARE_PROTECTION"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["EBS_MALWARE_PROTECTION"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["EKS_AUDIT_LOGS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["EKS_AUDIT_LOGS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["LAMBDA_NETWORK_LOGS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["LAMBDA_NETWORK_LOGS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["RDS_LOGIN_EVENTS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["RDS_LOGIN_EVENTS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["RUNTIME_MONITORING"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["RUNTIME_MONITORING"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_detector_feature.ntc_guardduty["S3_DATA_EVENTS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_detector_feature.ntc_guardduty["S3_DATA_EVENTS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration.ntc_guardduty[0]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration.ntc_guardduty[0]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["EBS_MALWARE_PROTECTION"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["EBS_MALWARE_PROTECTION"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["EKS_AUDIT_LOGS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["EKS_AUDIT_LOGS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["LAMBDA_NETWORK_LOGS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["LAMBDA_NETWORK_LOGS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["RDS_LOGIN_EVENTS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["RDS_LOGIN_EVENTS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["RUNTIME_MONITORING"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["RUNTIME_MONITORING"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_organization_configuration_feature.ntc_guardduty["S3_DATA_EVENTS"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_organization_configuration_feature.ntc_guardduty["S3_DATA_EVENTS"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_guardduty_publishing_destination.ntc_guardduty[0]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_guardduty_publishing_destination.ntc_guardduty[0]
}

# -------------------------------------------------------------------------------------------------------------------
# INSPECTOR - FRANKFURT (eu-central-1)
# -------------------------------------------------------------------------------------------------------------------
moved {
  from = module.ntc_regional_security_config_euc1.aws_inspector2_enabler.ntc_inspector[0]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_inspector2_enabler.ntc_inspector[0]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_inspector2_organization_configuration.ntc_inspector[0]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_inspector2_organization_configuration.ntc_inspector[0]
}

# -------------------------------------------------------------------------------------------------------------------
# IAM ACCESS ANALYZER - FRANKFURT (eu-central-1)
# -------------------------------------------------------------------------------------------------------------------
moved {
  from = module.ntc_regional_security_config_euc1.aws_accessanalyzer_analyzer.ntc_analyzer["ntc-external-access-analysis"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_accessanalyzer_analyzer.ntc_analyzer["ntc-external-access-analysis"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_accessanalyzer_analyzer.ntc_analyzer["ntc-unused-access-analysis"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_accessanalyzer_analyzer.ntc_analyzer["ntc-unused-access-analysis"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-external-access-analysis/archive-all-not-public"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-external-access-analysis/archive-all-not-public"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-external-access-analysis/archive-all-ntc-userids"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-external-access-analysis/archive-all-ntc-userids"]
}

moved {
  from = module.ntc_regional_security_config_euc1.aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-unused-access-analysis/archive-all-aws-sso-roles"]
  to   = module.ntc_security_tooling.module.regional_security_config["eu-central-1"].aws_accessanalyzer_archive_rule.ntc_analyzer["ntc-unused-access-analysis/archive-all-aws-sso-roles"]
}

# -------------------------------------------------------------------------------------------------------------------
# REPEAT FOR ADDITIONAL REGIONS (us-east-1, eu-central-2, etc.)
# -------------------------------------------------------------------------------------------------------------------
# Copy the blocks above and replace:
# - module.ntc_regional_security_config_euc1 → module.ntc_regional_security_config_use1
# - ["eu-central-1"] → ["us-east-1"]
# - Adjust analyzer names if using regional overrides (e.g., "ntc-external-access-analysis-use1")