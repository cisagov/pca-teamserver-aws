#!/usr/bin/env bash

# Usage:
#   terraform/delete_tfvars.sh <tfvars_filename_no_extension>

set -o nounset
set -o errexit
set -o pipefail

# Delete the current version of $1.tfvars from an S3 bucket.
#
# Note that this script requires that the AWS command line interface
# be installed on your system.

TERRAFORM_TFVARS_S3_BUCKET="ncats-terraform-production-tfvars"
TERRAFORM_DIR="terraform-pca-teamserver"
TFVARS_FILE="$1.tfvars"

aws s3 rm s3://"$TERRAFORM_TFVARS_S3_BUCKET"/"$TERRAFORM_DIR"/"$TFVARS_FILE"
