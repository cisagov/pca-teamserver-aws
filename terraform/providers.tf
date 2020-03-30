# This is the default Terraform provider that is used if no
# other provider is specified.
provider "aws" {
  region = var.aws_region
}

# This is the provider that can make changes to DNS entries
# in the cyber.dhs.gov zone.
provider "aws" {
  alias   = "dns"
  profile = "cool-dns-route53resourcechange-cyber.dhs.gov"
  region  = var.aws_region # route53 is global, but still required by Terraform
}
