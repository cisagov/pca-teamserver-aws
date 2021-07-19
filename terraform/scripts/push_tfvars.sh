#!/usr/bin/env bash

# Usage:
#   terraform/push_tfvars.sh <tfvars_filename_no_extension>

set -o nounset
set -o errexit
set -o pipefail

# Push your local version of $1.tfvars to the correct S3 bucket so
# that it can be used by others.
#
# Note that this script requires that the AWS command line interface
# be installed on your system.

TERRAFORM_TFVARS_S3_BUCKET="ncats-terraform-production-tfvars"
TERRAFORM_DIR="terraform-pca-teamserver"
TFVARS_FILE="$1.tfvars"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

aws s3 cp "$SCRIPT_DIR"/../"$TFVARS_FILE" s3://$TERRAFORM_TFVARS_S3_BUCKET/"$TERRAFORM_DIR"/"$TFVARS_FILE"
