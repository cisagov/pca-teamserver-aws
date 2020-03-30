data "aws_route53_zone" "public_zone" {
  name = local.public_zone
}

resource "aws_route53_record" "teamserver_pub_A" {
  provider = aws.dns
  
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = "teamserver.${terraform.workspace}.${local.public_subdomain}${data.aws_route53_zone.public_zone.name}"
  type    = "A"
  ttl     = 30
  records = [
    aws_eip.teamserver_eip.public_ip,
  ]
}
