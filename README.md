<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 1.3.0)

- aws (~> 5.33)

## Providers

The following providers are used by this module:

- aws (~> 5.33)

- aws.euc1 (~> 5.33)

## Modules

The following Modules are called:

### ntc\_parameters\_reader

Source: github.com/nuvibit-terraform-collection/terraform-aws-ntc-parameters//modules/reader

Version: 1.1.4

### ntc\_parameters\_writer

Source: github.com/nuvibit-terraform-collection/terraform-aws-ntc-parameters//modules/writer

Version: 1.1.4

### ntc\_regional\_security\_config\_euc1

Source: github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling//modules/regional-security-config

Version: 1.7.0

### ntc\_security\_tooling

Source: github.com/nuvibit-terraform-collection/terraform-aws-ntc-security-tooling

Version: 1.7.0

## Resources

The following resources are used by this module:

- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_guardduty_detector.euc1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/guardduty_detector) (data source)
- [aws_region.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### account\_id

Description: The current account id

### default\_region

Description: The default region name

### ntc\_parameters

Description: Map of all ntc parameters
<!-- END_TF_DOCS -->