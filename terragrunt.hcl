# =============================================================================
# ROOT terragrunt.hcl
# Inherited by all modules under live/
# =============================================================================

locals {
  # Read environment-specific values from the nearest account.hcl
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  environment         = local.account_vars.locals.environment
  account_id          = local.account_vars.locals.account_id
  aws_region          = local.account_vars.locals.aws_region
}

# ---------------------------------------------------------------------------
# Remote state — auto-generated backend.tf per module/environment
# ---------------------------------------------------------------------------
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "wholefin-tfstate-${local.environment}-${local.account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "wholefin-tfstate-lock"
    encrypt        = true
  }
}

# ---------------------------------------------------------------------------
# Provider — auto-generated provider.tf per module
# ---------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/Danny-TF"
    external_id  = "52a15c10-bcf9-43f4-aa7b-dbb937267218"
  }
}

# CloudFront + WAFv2 (CLOUDFRONT scope) must live in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/Danny-TF"
    external_id  = "52a15c10-bcf9-43f4-aa7b-dbb937267218"
  }
}
EOF
}
