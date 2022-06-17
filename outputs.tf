/**
 * @author Adnan Pasic
 * @email pasica@gmail.com
 * @create date 2022-06-17 22:25:48
 * @modify date 2022-06-17 22:25:48
 * @desc Terraform AWS Loadbalancer + subdomain
 */
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