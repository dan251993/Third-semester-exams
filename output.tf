output "alb_danlb_dns" {
  value = aws_lb.danlb.dns_name

}

output "alb_target_group_arn" {
  value = aws_lb_target_group.alb-dan.arn

}

output "Alb_zone_id" {
  value = aws_lb.danlb.zone_id
}
