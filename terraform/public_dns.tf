resource "aws_route53_record" "teamserver_pub_A" {
  provider = aws.dns

  zone_id = data.terraform_remote_state.dns.outputs.cyber_dhs_gov_zone.id
  name    = "teamserver.${terraform.workspace}.${local.public_subdomain}${data.terraform_remote_state.dns.outputs.cyber_dhs_gov_zone.name}"
  type    = "A"
  ttl     = 30
  records = [
    aws_eip.teamserver_eip.public_ip,
  ]
}
