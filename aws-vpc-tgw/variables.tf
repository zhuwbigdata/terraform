# Variable declarations
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "instance_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 1
}

variable "jumphost_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 1
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Enable a NAT gateway in your VPC."
  type        = bool
  default     = false
}

variable "jumphost_cidr_blocks" {
  description = "Available cidr blocks to access jumphost."
  type        = list(string)
  default     = [
    "24.15.64.206/32",
  ]
}

variable "ec2_keypair_name" {
  description = ""
  type        = string
  default     = "wayne-aws-keypair"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "mdwlab-test1",
    environment = "dev"
  }
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "vpc1_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public1_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24",
    "10.1.4.0/24",
    "10.1.5.0/24",
    "10.1.6.0/24",
    "10.1.7.0/24",
    "10.1.8.0/24",
  ]
}

variable "private1_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.1.101.0/24",
    "10.1.102.0/24",
    "10.1.103.0/24",
    "10.1.104.0/24",
    "10.1.105.0/24",
    "10.1.106.0/24",
    "10.1.107.0/24",
    "10.1.108.0/24",
  ]
}



variable "vpc2_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}


variable "public2_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24",
    "10.2.4.0/24",
    "10.2.5.0/24",
    "10.2.6.0/24",
    "10.2.7.0/24",
    "10.2.8.0/24",
  ]
}

variable "private2_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.2.101.0/24",
    "10.2.102.0/24",
    "10.2.103.0/24",
    "10.2.104.0/24",
    "10.2.105.0/24",
    "10.2.106.0/24",
    "10.2.107.0/24",
    "10.2.108.0/24",
  ]
}
