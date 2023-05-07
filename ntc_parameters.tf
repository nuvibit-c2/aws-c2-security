locals {
  ntc_parameters_bucket_name = "aws-c2-ntc-parameters"
  ntc_parameters_writer_node = "security"

  # map of parameters merged from all parameter nodes
  ntc_parameters = module.ntc_parameters_reader.all_parameters

  # parameters that are managed by core security account
  ntc_parameters_to_write = {
    config : {}
    config_member : {}
    security_hub : {}
    security_hub_member : {}
    guard_duty : {}
    guard_duty_member : {}
  }

  # by default existing node parameters will be merged with new parameters to avoid deleting parameters
  replace_parameters = true
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC PARAMETERS - READER
# ---------------------------------------------------------------------------------------------------------------------
module "ntc_parameters_reader" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-parameters//modules/reader?ref=beta"

  bucket_name = local.ntc_parameters_bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ NTC PARAMETERS - WRITER
# ---------------------------------------------------------------------------------------------------------------------
module "ntc_parameters_writer" {
  source = "github.com/nuvibit-terraform-collection/terraform-aws-ntc-parameters//modules/writer?ref=beta"

  bucket_name     = local.ntc_parameters_bucket_name
  parameter_node  = local.ntc_parameters_writer_node
  node_parameters = local.ntc_parameters_to_write
}
