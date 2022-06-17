# Set number of instances
variable "instance_nmb" {
  type        = number
  description = "Instance number"
  default     = 2
}

# Set region 
variable "region" {
  type        = string
  description = "Region Zona"
  default     = "ca-central-1"
}

# Set domain
variable "domain" {
  type        = string
  description = "Root domain"
  default     = "awsmostar.com"
}

# Set sub-domain
variable "subdomain" {
  type        = string
  description = "Sub domain"
  default     = "adnan-pasic-tf"
}

# Set public ssh key
variable "ssh_key_pair" {
  type        = string
  description = "SSH key pair to be provisioned on the instance"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSDv91Cu4gM37m1jo5gk2ONrLz1d1aeIavFmCefjBJFkPspWDjFw/zZP+Z1Zy3XQxLwNs6qiAWDfU0TW7COIuCna0KMTkvJgmY/zwwMi7skpUycWGpwKl5dY7ZG3/5/HzfknCiLTtYiOubdC5jUU5ndQavnp8Q1sPCQ9tO7KAyF5K3Lf2P659sxXt0NewM5NN2LQHI4PKxzT2zYEgzo7cbbZjJd1WMilE99UFGAiFgNBS09ek30YrN6BkSKK9v8y2NVkoC/Ihe73y71ZaRyFvM+LhG4KFfrVRUh+Y1eUj/NekWoZNjWdBkRvuRDFuAdclbIPJ8GOB2RkO/VuDd/KCKt5WFaqk3JnZE+NX9xlJQwsPqW8fxYxPbUgC20GcK06nc2jFPtXOi+vOsgcZ93QTe19sG0grHNAtv+37BODs52HSn5ZTozXnrVLJlt9zuln5rzg4topl6qDQWV7Ey0tmgHmE+7jUQJqf7JCpi+uOEGgkK/PzZIoAzMtikRshZG88= paja@apasic-lap"
}

# Set AMI images in current region
variable "ami_id" {
  type        = string
  description = "AMI image"
  # default     = "ami-0e7e134863fac4946"
  # default     = "ami-09439f09c55136ecf"
  default     = "ami-0843f7c45354d48b5"

}

# Set subnets in current region
variable "subnets" {
    type = list
    default = ["subnet-01af2c8ccfbe661ec","subnet-0a451572b818de6f7","subnet-01a352f599dfe34c0"]
}

# Set VPC in current region
variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "vpc-07fea8cf59ec86f75"
}

# Prefix for services 
variable "prefix_name" {
  type        = string
  description = "Server name prefix"
  default     = "adnan-pasic-tf"
}

# Health check variables
variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "80"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}