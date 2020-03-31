# This is the default Terraform provider that is used if no
# other provider is specified.
provider "aws" {
  region = var.aws_region
}

# This is the provider that can make changes to DNS entries
# in the cyber.dhs.gov zone.
#
# NOTE: After we begin deploying these TeamServers in the COOL, it
# will be possible to assume the role below via Terraform remote
# state.  For details see:
# https://github.com/cisagov/pca-teamserver-aws/pull/30#discussion_r400610194
provider "aws" {
  alias   = "dns"
  profile = "cool-dns-route53resourcechange-cyber.dhs.gov"
  region  = var.aws_region # route53 is global, but still required by Terraform
}
