/**
 * @author Adnan Pasic
 * @email pasica@gmail.com
 * @create date 2022-06-17 22:16:13
 * @modify date 2022-06-17 22:16:13
 * @desc Terraform AWS Loadbalancer + subdomain
 */
###################### ZONE
provider "aws" {
  region  = var.region
}
###################### ZONE
###################### SG
resource "aws_security_group" "sg-web-server" {
  name        = "${var.prefix_name}-sg-web-server"
  description = "Allow HTTP and SSH"
   vpc_id      = var.vpc_id
 
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.prefix_name}-sg-web-server"
}
}
###################### SG
###################### SSH KEY
resource "aws_key_pair" "key-web-server" {
  key_name   = "${var.prefix_name}-key-web-server"
  public_key = var.ssh_key_pair
}
###################### SSH KEY
###################### EC2
resource "aws_instance" "myInstance" {
  count = var.instance_nmb
  ami           = var.ami_id
  instance_type = "t2.micro"
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  echo '<h2><p style="color:blue;"> My Instance! - EC2 LB </p></h2>' >> /var/www/html/index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
  tags = {
  #Name = var.srv_name 
  #Name = "WebServer-${count.index}"
  Name = "${var.prefix_name}-ec2-web-server-${count.index + 1}"

  }
  security_groups = ["${var.prefix_name}-sg-web-server"]
  key_name        = "${var.prefix_name}-key-web-server"
}
###################### EC2
###################### TG
resource "aws_lb_target_group" "web-server-tg" {
  name     = "${var.prefix_name}-web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}
###################### TG
# ###################### 
# resource "aws_vpc" "main" {
#   cidr_block = "172.31.0.0/16"
# }
# ###################### 
###################### TG ATTACH
resource "aws_lb_target_group_attachment" "web-server-tg" {
  count = length(aws_instance.myInstance)
  target_group_arn = aws_lb_target_group.web-server-tg.arn
  target_id        = aws_instance.myInstance[count.index].id
  port             = 80
}
###################### TG ATTACH
###################### LB SG
resource "aws_security_group" "sg-lb-web-server" {
  name        = "${var.prefix_name}-sg-lb-web-server"
  description = "Allow HTTP"
   vpc_id      = var.vpc_id
 
   ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.prefix_name}-sg-lb-web-server"
}
}

resource "aws_security_group_rule" "inbound_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  source_security_group_id = aws_security_group.sg-lb-web-server.id
  security_group_id = aws_security_group.sg-web-server.id
}
###################### LB SG
###################### LB
resource "aws_lb" "lb-web-server" {
  name            = "${var.prefix_name}-lb-web-server"
  subnets         = var.subnets
  security_groups = [aws_security_group.sg-lb-web-server.id]

  tags = merge(
    {
      Name = "${var.prefix_name}-lb-web-server"
    }
  )
   enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "lb-web-server" {
  load_balancer_arn = aws_lb.lb-web-server.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server-tg.arn
  }
}
###################### LB
###################### DNS
data "aws_route53_zone" "selected" {
  name         = "${var.domain}."
  private_zone = false
}

resource "aws_route53_record" "alias_route53_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain}.${data.aws_route53_zone.selected.name}"	
  type    = "A"

  alias {
    name                   = aws_lb.lb-web-server.dns_name
    zone_id                = aws_lb.lb-web-server.zone_id
    evaluate_target_health = true
  }
}
###################### DNS