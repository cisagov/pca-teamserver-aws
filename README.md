# NCATS PCA Teamserver in AWS #

[![Build Status](https://travis-ci.com/cisagov/pca-teamserver-aws.svg?branch=develop)](https://travis-ci.com/cisagov/pca-teamserver-aws)

Build AMI via Packer with:
```
packer packer/teamserver.json
```

Build Terraform infrastructure with:
```
cd terraform
terraform workspace select <your_workspace>
terrafrom init --upgrade
terraform apply -var-file=<your_workspace>.tfvars
```

## Contributing ##

We welcome contributions!  Please see [here](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE.md).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
