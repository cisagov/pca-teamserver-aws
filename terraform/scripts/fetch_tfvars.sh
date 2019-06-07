#!/usr/bin/env bash

# Usage:
#   terraform/fetch_tfvars.sh <tfvars_filename_no_extension>

set -o nounset
set -o errexit
set -o pipefail

# Fetch the current version of $1.tfvars from an S3 bucket and put it
# in the terraform directory.
#
# Note that this script requires that the AWS command line interface
# be installed on your system.

TERRAFORM_TFVARS_S3_BUCKET="ncats-terraform-production-tfvars"
TERRAFORM_DIR="terraform-pca-teamserver"
TFVARS_FILE="$1.tfvars"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

aws s3 cp s3://"$TERRAFORM_TFVARS_S3_BUCKET"/"$TERRAFORM_DIR"/"$TFVARS_FILE" "$SCRIPT_DIR"/../"$TFVARS_FILE"
