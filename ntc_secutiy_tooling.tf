# =====================================================================================================================
# NTC SECURITY TOOLING - CENTRALIZED CLOUD SECURITY POSTURE MANAGEMENT (CSPM)
# =====================================================================================================================
# Centralized security monitoring and automation platform aggregating security findings from across the entire
# AWS organization into a single pane of glass for comprehensive threat detection and compliance management.
#
# WHAT IS NTC SECURITY TOOLING?
# ------------------------------
# A centralized Cloud Security Posture Management (CSPM) solution built on AWS Security Hub that:
#   ✓ Aggregates security findings from all accounts and regions in the organization
#   ✓ Processes findings through custom Step Functions workflows (enrichment, automation, notification)
#   ✓ Enforces consistent security standards across the organization via central configuration policies
#   ✓ Provides intelligent notification routing with both human-readable and machine-readable formats
#
# SECURITY SERVICES AGGREGATED:
# ------------------------------
# All findings flow into the centralized Security Hub for unified visibility:
#   ✓ AWS Config: Continuous compliance monitoring and resource configuration tracking
#   ✓ Amazon GuardDuty: Intelligent threat detection using machine learning
#   ✓ Amazon Inspector: Automated vulnerability assessment for EC2, Lambda, ECR
#   ✓ IAM Access Analyzer: External access and unused access detection
#   ✓ AWS Security Hub Standards: CIS, NIST, PCI-DSS, AWS Foundational Security Best Practices
#
# WHY STEP FUNCTIONS INSTEAD OF NATIVE SECURITY HUB AUTOMATION RULES?
# --------------------------------------------------------------------
# AWS Security Hub provides native automation rules, but NTC Security Tooling uses a custom Step Functions-based
# processing engine to overcome critical limitations and provide enhanced capabilities:
#
# NATIVE SECURITY HUB LIMITATIONS:
# --------------------------------
#   ✗ Rule Capacity: Limited to 100 automation rules per region (not scalable for large organizations)
#   ✗ No Notification Control: Cannot suppress or route notifications based on finding characteristics
#   ✗ Limited Enrichment: Basic field updates only, no custom organizational context
#   ✗ No Observability: Black box operation with no visibility into rule processing
#   ✗ Fixed Processing: Simple rule evaluation only, no complex workflows or branching logic
#
# NTC STEP FUNCTIONS ADVANTAGES:
# -------------------------------
#   ✓ Unlimited Rules: Process thousands of automation rules without AWS limitations
#   ✓ Granular Notification Control: Suppress RAW, PRETTY, or ALL notifications per finding
#   ✓ Deep Enrichment: Add account metadata, alternate contacts, tags, OU paths, cost centers
#   ✓ Full Observability: CloudWatch logs and Step Functions execution history for debugging
#   ✓ ASFF Compatibility: 100% compatible with AWS Security Finding Format (ASFF) syntax
#
# PROCESSING PIPELINE:
# --------------------
# Finding Flow: Member Account → Security Hub → EventBridge → Step Functions → Lambda Functions
#
# Step 1: ENRICHMENT Lambda
#   • Adds organizational context from AWS Organizations API (cached in DynamoDB)
#   • Fields added: Account name, email, OU path, account tags, alternate contacts
#   • Purpose: Enable sophisticated automation rules based on organizational metadata
#
# Step 2: PROCESSING Lambda
#   • Evaluates automation rules sequentially (RuleOrder) using ASFF syntax
#   • Updates finding fields (severity, workflow status, notes, user-defined fields)
#   • Purpose: Automated finding management without manual intervention
#
# Step 3: NOTIFICATION Lambda
#   • Routes findings to SNS topics based on severity and suppression rules
#   • PRETTY format: Human-readable HTML emails for security teams
#   • RAW format: Complete ASFF JSON for webhooks, ticketing systems, automated remediation
#   • Purpose: Intelligent notification delivery to appropriate teams and systems
#
# ⚠️  CRITICAL PREREQUISITES:
# --------------------------
# NTC Security Tooling requires several components to be configured BEFORE deployment:
#
# 1. ADMIN DELEGATIONS (via NTC Organizations):
#    • securityhub.amazonaws.com - Central Security Hub aggregation
#    • guardduty.amazonaws.com - Threat detection findings
#    • inspector2.amazonaws.com - Vulnerability assessment findings
#    • access-analyzer.amazonaws.com - External/unused access findings
#    • config.amazonaws.com - Compliance and configuration tracking
#
# 2. AWS CONFIG (via NTC Account Factory baseline):
#    • Config must be enabled in ALL accounts and regions
#    • Config recorder must be running and delivering to S3
#    • Config is the foundation for Security Hub compliance checks
#    • Deploy via NTC Account Factory baseline templates for organization-wide rollout
#
# 3. CROSS-ACCOUNT IAM ROLE (in Management Account) - OPTIONAL:
#    • Role name: ntc-org-account-reader (configurable)
#    • Purpose: Only required if enriching findings with alternate contacts (security, operations, billing)
#    • Permissions: account:GetAlternateContact
#    • Note: Basic account metadata (name, email, OU path, tags) is accessible without this role
#
# DEPLOYMENT ORDER:
# -----------------
# 1. Deploy NTC Organizations → Create admin delegations & cross-account IAM role
# 2. Deploy NTC Account Factory → Rollout Config via baseline templates to all accounts
# 3. Deploy NTC Security Tooling (this module)
#
# REGIONAL CONSIDERATIONS:
# ------------------------
# Security Hub Aggregation Limitation:
#   ⚠️  Home region (where this module runs) MUST be a standard AWS region (not opt-in)
#   ⚠️  Opt-in regions (e.g., Zurich eu-central-2) cannot be used as aggregation region
#   ⚠️  Linked regions can be any supported region (standard or opt-in)
#   Reference: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-regions.html
#
# Multi-Region Setup:
#   • Home Region: Hosts central Security Hub and Step Functions pipeline (eu-central-1 in this example)
#   • Linked Regions: Findings aggregated from these regions to home region (eu-central-2, us-east-1)
#   • Central configuration policies automatically apply to all linked regions
#
# ⚠️  WORKAROUND FOR OPT-IN HOME REGIONS:
#   Option 1: Deploy NTC Security Tooling in a standard region (RECOMMENDED)
#     • Deploy this module in a nearby standard region (e.g., Frankfurt eu-central-1)
#     • Aggregate findings from all regions including your opt-in home region
#     • Benefit: Full central configuration and aggregation capabilities
#     • Example: Security Tooling in eu-central-1, aggregating from eu-central-2, us-east-1
#
# NOTIFICATION STRATEGY:
# ----------------------
# NTC Security Tooling provides two notification formats for different use cases:
#
# PRETTY Notifications (Human-Readable):
#   • Format: HTML email with formatted tables and highlighting
#   • Content: Account context, severity, resource details, remediation guidance
#   • Use Case: Security team email alerts, executive summaries
#
# RAW Notifications (Machine-Readable):
#   • Format: Complete ASFF JSON payload
#   • Content: All finding fields, enriched metadata, full resource details
#   • Use Case: Webhooks, Lambda processing, ticketing systems (Jira, ServiceNow)
#
# Notification Suppression (via automation rules):
#   • RAW suppression: Block JSON notifications while allowing pretty emails
#   • PRETTY suppression: Block emails while keeping raw data flow for automation
#   • ALL suppression: Complete notification blackout for specific findings
#
# SECURITY STANDARDS STRATEGY:
# ----------------------------
# ⚠️  IMPORTANT: Only enable the LATEST version of each standard to avoid duplicate findings!
#
# Recommended Standards:
#   ✓ aws-foundational-security-best-practices/v/1.0.0 (ALWAYS enable - AWS baseline)
#   ✓ cis-aws-foundations-benchmark/v/5.0.0 (Latest version only - industry best practices)
#   ✓ nist-800-53/v/5.0.0 (For regulated industries, ISO 27001, NIS2 compliance)
#   ✓ pci-dss/v/4.0.1 (Only if processing payment card data)
#
# Why only latest versions?
#   • Multiple versions generate duplicate findings for the same issues
#   • Increases costs (more findings to process and store)
#   • Creates alert fatigue from redundant notifications
#   • Makes compliance reporting unclear (which version to follow?)
#
# =====================================================================================================================

# =====================================================================================================================
# TERRAFORM IMPORT - AVOID SECURITY HUB CREATION CONFLICT
# =====================================================================================================================
# AWS automatically enables Security Hub when creating the admin delegation in Organizations
# This causes a Terraform error when NTC Security Tooling tries to create Security Hub
#
# Import the existing Security Hub account into Terraform state before applying
#
# Use the import block (Terraform 1.5+):
# =====================================================================================================================
import {
  to = module.ntc_security_tooling.aws_securityhub_account.ntc_securityhub_central
  id = data.aws_caller_identity.current.account_id
}

# =====================================================================================================================
# NTC SECURITY TOOLING - MAIN MODULE
# =====================================================================================================================
# Centralized CSPM solution with custom Step Functions processing pipeline
#
# AUTOMATIC FEATURES:
# -------------------
# The module automatically configures:
#   ✓ Security Hub aggregation from all accounts and regions
#   ✓ EventBridge rules to trigger Step Functions on finding changes
#   ✓ Lambda functions for enrichment, processing, and notification
#   ✓ SNS topics for pretty and raw notifications
#   ✓ IAM roles and policies for all components
#   ✓ CloudWatch log groups for observability
#
# CONFIGURATION SECTIONS:
# -----------------------
# 1. Security Hub Aggregation: Multi-region finding collection
# 2. Enrichment Settings: Add organizational context to findings
# 3. Notification Settings: SNS-based alerting with two formats
# 4. Report Settings: Scheduled security reports
# 5. Processing Settings: Custom automation rules
# 6. Central Configuration Policies: Organization-wide security standards
# =====================================================================================================================
module "ntc_security_tooling" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling?ref=1.8.0"

  # -------------------------------------------------------------------------------------------------------------------
  # SECURITY HUB STANDARDS CONFIGURATION
  # -------------------------------------------------------------------------------------------------------------------
  # Strategy: Use central configuration policies (below) instead of default standards
  # This provides organization-wide consistency and prevents configuration drift
  # -------------------------------------------------------------------------------------------------------------------
  # set to true to enable securityhub standards that securityhub has designated as automatically enabled
  # use 'securityhub_central_configuration_polices' to configure security standards across entire aws organizations
  enable_securityhub_default_standards = false

  # -------------------------------------------------------------------------------------------------------------------
  # SECURITY HUB AGGREGATION - MULTI-REGION FINDING COLLECTION
  # -------------------------------------------------------------------------------------------------------------------
  # Aggregates findings from all accounts and regions into this central Security Hub
  #
  # ARCHITECTURE:
  #   • Home Region: eu-central-1 (Frankfurt) - hosts central Security Hub and Step Functions
  #   • Linked Regions: eu-central-2 (Zurich), us-east-1 (N. Virginia) - findings flow to home region
  #
  # REQUIREMENT:
  #   • Home region MUST be a standard AWS region (not opt-in)
  #   • Admin delegation for 'securityhub.amazonaws.com' required
  #
  # BENEFITS:
  #   ✓ Single pane of glass for all security findings
  #   ✓ Unified processing pipeline (one Step Functions workflow)
  #   ✓ Centralized notification and reporting
  #   ✓ Consistent automation rules across all regions
  # -------------------------------------------------------------------------------------------------------------------
  # securityhub aggregration is required for central configuration
  enable_securityhub_central_configuration = true
  enable_securityhub_aggregation           = true
  # can be either "ALL_REGIONS" or a list of regions which should be aggregated
  # this will also apply the central configuration policies to the specified regions
  #
  # CHOOSING BETWEEN ALL_REGIONS VS SPECIFIC REGIONS:
  # --------------------------------------------------
  # AWS Recommendation (All Regions):
  #   • Set to "ALL_REGIONS" to enable Security Hub in every AWS region
  #   • Benefit: Get notified if resources are deployed in unintended regions (shadow IT detection)
  #   • Drawback: Extremely costly - generates findings from all regions even if unused
  #   • Drawback: High alert fatigue - thousands of findings from empty regions
  #
  # Nuvibit Recommendation (Specific Regions):
  #   • List only regions actively in use by your organization (e.g., eu-central-1, us-east-1)
  #   • Benefit: Cost-effective - only pay for findings in regions with actual workloads
  #   • Benefit: Efficient - focus security team on findings that matter
  #   • Requirement: Use guardrails via NTC Organization to prevent deployments in unauthorized regions
  #
  # Example Cost Impact:
  #   • ALL_REGIONS: 33 regions × 5 services × 1000 findings = 165,000 findings/month
  #   • Specific Regions: 2 regions × 5 services × 1000 findings = 10,000 findings/month
  #   • Savings: ~94% reduction in findings and associated processing costs
  #
  # Recommendation: Use specific regions + guardrails for cost optimization
  # --------------------------------------------------
  securityhub_aggregation_regions = [
    # "eu-central-1", current region must be excluded from this list
    "eu-central-2",
    "us-east-1"
  ]

  # -------------------------------------------------------------------------------------------------------------------
  # FINDING ENRICHMENT - ADD ORGANIZATIONAL CONTEXT
  # -------------------------------------------------------------------------------------------------------------------
  # Enrichment Lambda adds organizational metadata to every finding before processing
  #
  # ENRICHED FIELDS (added to UserDefinedFields):
  #   • NTC_ACCOUNT_NAME: Human-readable account name
  #   • NTC_ACCOUNT_EMAIL: Account root email address
  #   • NTC_ACCOUNT_STAGE: Environment classification (dev/test/prod)
  #   • NTC_OU_PATH: Organizational unit hierarchy
  #   • NTC_ALTERNATE_CONTACT_SECURITY: Security team contact (requires cross-account role)
  #   • NTC_ALTERNATE_CONTACT_OPERATIONS: Operations team contact (requires cross-account role)
  #   • NTC_ALTERNATE_CONTACT_BILLING: Billing team contact (requires cross-account role)
  #   • NTC_COST_CENTER: Financial attribution
  #   • Custom fields from SSM Parameters
  #
  # DATA SOURCES:
  #   AWS Organizations API (cached in DynamoDB for performance)
  #    - Basic metadata: Account name, email, OU path, tags (no cross-account role needed)
  #    - Alternate contacts: Requires cross-account role in Management account
  #
  # BENEFITS:
  #   ✓ Automation rules can filter by account stage (e.g., elevate severity for prod)
  #   ✓ Notifications include account context for faster triage
  #   ✓ Reports grouped by OU, cost center, or custom attributes
  #
  # OPTIONAL REQUIREMENT (for alternate contacts only):
  #   • Cross-account IAM role in Management account (via NTC Organizations)
  #   • Role name: ntc-org-account-reader (configurable below)
  #   • Permissions: account:GetAlternateContact
  #   • Note: Basic account metadata works without this role
  # -------------------------------------------------------------------------------------------------------------------
  # enrich securityhub findings with account context
  securityhub_enrichment_settings = {
    enable_enrichment = true
    # enrich only findings of specific severity from ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    severity_labels = ["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
    # to get alternate contact an assumable iam role is required in the org management account
    alternate_contact_assume_role = "ntc-org-account-reader"
  }

  # -------------------------------------------------------------------------------------------------------------------
  # NOTIFICATION SETTINGS - SNS-BASED ALERTING
  # -------------------------------------------------------------------------------------------------------------------
  # Intelligent notification routing with two formats: PRETTY (human) and RAW (machine)
  #
  # PRETTY NOTIFICATIONS (Human-Readable):
  #   • Format: HTML email with formatted tables, severity highlighting
  #   • Content: Account name, resource details, remediation guidance, documentation links
  #   • Use Case: Security team email alerts, executive summaries
  #   • Subscribers: Email addresses, Slack channels
  #
  # RAW NOTIFICATIONS (Machine-Readable):
  #   • Format: Complete ASFF JSON payload with all enriched fields
  #   • Content: Full finding data for programmatic processing
  #   • Use Case: Webhooks, Lambda functions, ticketing systems (Jira, ServiceNow)
  #   • Subscribers: HTTPS endpoints, Lambda functions, SQS queues
  #
  # NOTIFICATION SUPPRESSION (via automation rules):
  #   • Set NTC_SUPPRESS_NOTIFICATION in UserDefinedFields:
  #     - "RAW": Suppress JSON notifications (keep pretty)
  #     - "PRETTY": Suppress email notifications (keep raw)
  #     - "ALL": Suppress all notifications
  #
  # REMINDER LOGIC:
  #   • Unresolved findings trigger reminders based on severity (configurable)
  #   • CRITICAL: Daily reminders if not resolved
  #   • HIGH: Reminders every 3 days
  #   • MEDIUM: Reminders every 7 days
  #   • LOW/INFORMATIONAL: Reminders every 14 days
  #
  # ORG IDENTIFIER:
  #   • Used in notification subject lines to distinguish between multiple organizations
  # -------------------------------------------------------------------------------------------------------------------
  # get notified via sns topic about security hub findings
  securityhub_notification_settings = {
    enable_notifications = true
    # identify for which AWS Organization notifications are sent
    org_identifier = "c2"
    # prettified finding notifications for specific severities
    severity_labels_findings_pretty = ["CRITICAL", "HIGH"]

    subscriptions_findings_pretty = [
      {
        protocol  = "email"
        endpoints = ["operations+aws-c2@nuvibit.com"]
      }
    ]
    # raw json notifications for specific severities
    severity_labels_findings_raw = ["CRITICAL"]
    subscriptions_findings_raw   = []
    # define how frequent reminders for findings should be sent
    reminder_x_days_unresolved_by_severity = {
      critical      = 1
      high          = 3
      medium        = 7
      low           = 14
      informational = 14
    }
  }

  # -------------------------------------------------------------------------------------------------------------------
  # PROCESSING SETTINGS - CUSTOM AUTOMATION RULES
  # -------------------------------------------------------------------------------------------------------------------
  # Custom automation rules processed through Step Functions
  #
  # WHY CUSTOM PROCESSING?
  #   Native Security Hub: Limited to 100 rules per region, no notification control
  #   NTC Step Functions: Unlimited rules + notification suppression + deep enrichment
  #
  # AUTOMATION RULES SYNTAX:
  #   • 100% compatible with AWS Security Finding Format (ASFF)
  #   • Same Criteria and Actions as native Security Hub automation rules
  #   • Reference: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format.html
  #
  # RULE COMPONENTS:
  #   • Criteria: ASFF-based conditions for rule matching (ProductName, SeverityLabel, ResourceId, etc.)
  #   • Actions: Operations to perform on matching findings (update Severity, Workflow, Note, UserDefinedFields)
  #   • RuleOrder: Execution order (lower numbers execute first)
  #   • IsTerminal: Stop processing after this rule (true/false)
  #
  # COMMON USE CASES:
  #   • Severity Adjustment: Elevate findings to CRITICAL for production resources
  #   • False Positive Suppression: Mark known false positives as SUPPRESSED
  #   • Notification Control: Suppress PRETTY notifications for noisy findings
  #   • Environment-Based Processing: Different handling for dev/test/prod
  #   • Compliance Automation: Auto-suppress findings with compensating controls
  #
  # EXAMPLE RULE (Suppress Inspector email notifications):
  #   {
  #     "RuleName": "SUPPRESS_INSPECTOR_PRETTY",
  #     "Criteria": { "ProductName": [{ "Value": "Inspector", "Comparison": "EQUALS" }] },
  #     "Actions": [{
  #       "FindingFieldsUpdate": {
  #         "UserDefinedFields": { "NTC_SUPPRESS_NOTIFICATION": "PRETTY" }
  #       }
  #     }]
  #   }
  #
  # FILE FORMAT:
  #   • Define rules in JSON file (example_automation_rules.json)
  #   • Loaded via jsondecode(file()) for easier maintenance
  #   • Version control rules in Git alongside Terraform configurations
  # -------------------------------------------------------------------------------------------------------------------
  securityhub_processing_settings = {
    enable_processing = true
    # uses the security hub automation rules and asff syntax
    # https://docs.aws.amazon.com/securityhub/latest/userguide/automation-rules.html#automation-rules-criteria-actions
    # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format.html
    automation_rules = jsondecode(file("${path.module}/example_automation_rules.json"))
  }

  # -------------------------------------------------------------------------------------------------------------------
  # CENTRAL CONFIGURATION POLICIES - ORGANIZATION-WIDE SECURITY STANDARDS
  # -------------------------------------------------------------------------------------------------------------------
  # Apply consistent security standards across entire organization via centrally managed policies
  #
  # WHAT ARE CENTRAL CONFIGURATION POLICIES?
  #   • Centralized management of Security Hub settings from a single account
  #   • Automatically apply security standards to OUs or individual accounts
  #   • Prevent configuration drift (centrally managed accounts cannot change settings locally)
  #
  # BENEFITS:
  #   ✓ Consistency: Identical security configurations across all accounts
  #   ✓ Automation: New accounts automatically inherit security standards from their OU
  #   ✓ Compliance: Enforce minimum security baseline organization-wide
  #   ✓ Flexibility: Different policies for different OUs (prod vs dev vs sandbox)
  #
  # POLICY COMPONENTS:
  #   • enabled_standards: Which security frameworks to enable (AWS FSBP, CIS, NIST, PCI-DSS)
  #   • disabled_control_ids: Specific controls to disable (e.g., false positives, compensating controls)
  #   • customized_security_controls: Custom parameters for specific controls (e.g., password age)
  #   • policy_targets: OUs or account IDs where policy applies
  #
  # SECURITY STANDARDS STRATEGY:
  #   ⚠️  CRITICAL: Only enable LATEST version of each standard!
  #   
  #   Enabled Standards (this example):
  #     ✓ aws-foundational-security-best-practices/v/1.0.0 (AWS baseline - ALWAYS enable)
  #     ✓ cis-aws-foundations-benchmark/v/5.0.0 (Industry best practices - latest version only)
  #   
  #   Why only latest versions?
  #     • Multiple versions create duplicate findings (e.g., CIS v1.2 + v5.0 = same control twice)
  #     • Increases costs (more findings to process and store)
  #     • Creates alert fatigue from redundant notifications
  #     • Makes compliance unclear (which version are we following?)
  #   
  #   Additional Standards (enable based on compliance requirements):
  #     • nist-800-53/v/5.0.0: For regulated industries, ISO 27001, NIS2 compliance
  #     • pci-dss/v/4.0.1: Only if processing payment card data
  #     • aws-resource-tagging-standard/v/1.0.0: For strict tagging governance
  #
  # DISABLED CONTROLS:
  #   Controls disabled due to:
  #     • False positives (e.g., Athena primary workgroup always unencrypted by AWS design)
  #     • Compensating controls (e.g., MFA enforced at Identity Center instead of per account)
  #     • Business decisions (e.g., allow SSH from specific IPs via automation rule instead)
  #     • Alternative implementations (e.g., Config managed by NTC Account Factory baseline)
  #
  # POLICY TARGETS:
  #   • Management Account: Included explicitly (not in any OU)
  #   • Core OU: Log Archive, Security, Network accounts
  #   • Workloads OU: Application accounts (dev, test, prod)
  #   • Sandbox OU: Excluded (developers need flexibility for experimentation)
  #   • Suspended OU: Excluded (accounts under investigation or cleanup)
  #
  # ROLLOUT STRATEGY:
  #   1. Start with core accounts (management, security, network)
  #   2. Test in non-production workload accounts
  #   3. Gradually expand to production workload accounts
  #   4. Exclude sandbox accounts to maintain developer flexibility
  #   5. Monitor findings and adjust 'disabled_control_ids' as needed
  # -------------------------------------------------------------------------------------------------------------------
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
        local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/core"],
        local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/workloads"],

        # policy will not be rolled out to sandbox accounts and to suspended or accounts in transition
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/sandbox"],
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/suspended"],

        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root/transition"],
        # to apply policy to all accounts in organization use /root parent ou as target
        # local.ntc_parameters["mgmt-organizations"]["ou_ids"]["/root"]
      ]
      enabled_standards = [
        "aws-foundational-security-best-practices/v/1.0.0",
        # "aws-resource-tagging-standard/v/1.0.0",
        # "cis-aws-foundations-benchmark/v/1.2.0",
        # "cis-aws-foundations-benchmark/v/1.4.0",
        # "cis-aws-foundations-benchmark/v/3.0.0",
        "cis-aws-foundations-benchmark/v/5.0.0",
        # "nist-800-171/v/2.0.0",
        # "nist-800-53/v/5.0.0",
        # "pci-dss/v/3.2.1",
        # "pci-dss/v/4.0.1",
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

  # -------------------------------------------------------------------------------------------------------------------
  # REPORT SETTINGS - SCHEDULED SECURITY REPORTS
  # -------------------------------------------------------------------------------------------------------------------
  # Generate and deliver scheduled security reports via SNS
  #
  # AVAILABLE REPORTS:
  #   • securityhub-summary: High-level overview of findings by severity and compliance status
  #
  # SCHEDULING:
  #   • Schedule reports to be generated every X days
  #   • Reports sent via email to configured subscribers
  #   • Useful for weekly security reviews, monthly compliance reporting
  #
  # USE CASES:
  #   • Weekly security posture reports for security team
  #   • Monthly compliance reports for audit team
  #   • Executive summaries for leadership team
  # -------------------------------------------------------------------------------------------------------------------
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
          endpoints = ["operations+aws-c2@nuvibit.com"]
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
