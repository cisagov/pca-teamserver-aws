# NCATS PCA Teamserver in AWS #

[![GitHub Build Status](https://github.com/cisagov/pca-teamserver-aws/workflows/build/badge.svg)](https://github.com/cisagov/pca-teamserver-aws/actions)

Build AMI via Packer with:

```console
packer build packer/teamserver.json
```

Build Terraform infrastructure with:

```console
cd terraform
terraform workspace select <your_workspace>
terrafrom init --upgrade
terraform apply -var-file=<your_workspace>.tfvars
```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
