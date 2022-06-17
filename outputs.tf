# Print public DNS for instances
output "DNS" {
  #value = aws_instance.myInstance.public_dns
  value = aws_instance.myInstance[*].public_dns
}

# Print public DNS for loadbalancer
output "alb_dns_name" {
  value = aws_lb.lb-web-server.dns_name
}

# Print register domain
output "domain_lb" {
  value = "${var.subdomain}.${data.aws_route53_zone.selected.name}"
}