resource "aws_route53_zone" "hosted_zone" {
  name = "dembeemu.tk"
}
resource "aws_route53_record" "subdomain" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "terraform-test.dembeemu.tk"
  type    = "A"
  alias {
    name                   = aws_lb.danlb.dns_name
    zone_id                = aws_lb.danlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "test" {
  allow_overwrite = true
  name            = "dembeemu.tk"
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.hosted_zone.zone_id

  records = [
    aws_route53_zone.hosted_zone.name_servers[0],
    aws_route53_zone.hosted_zone.name_servers[1],
    aws_route53_zone.hosted_zone.name_servers[2],
    aws_route53_zone.hosted_zone.name_servers[3],
  ]
}
