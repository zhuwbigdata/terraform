terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks,  0, var.public_subnet_count)

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.resource_tags
}


module "jumphost_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "jumphost-ssh-sg-mdwlab-dev"
  description = "Security group for jumphost in public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.jumphost_cidr_blocks
  tags = var.resource_tags
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name        = "lb-sg-mdwlab-dev"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.resource_tags
}



module "app_security_group1" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "3.17.0"

  name        = "app-lb-sg-mdwlab-dev"
  description = "Security group for web-servers with HTTP ports open within Load Balancer"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  computed_ingress_with_source_security_group_id = [
    {
      rule = "http-80-tcp"
      source_security_group_id = module.lb_security_group.this_security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  tags = var.resource_tags
}

module "app_security_group2" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "app-ssh-sg-mdwlab-dev"
  description = "Security group for webservers with SSH ports"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  tags = var.resource_tags
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.4.0"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-mdwlab-dev"

  internal = true

  security_groups = [module.lb_security_group.this_security_group_id]
  subnets         = module.vpc.private_subnets

  number_of_instances = length(module.ec2_instances.instance_ids)
  instances           = module.ec2_instances.instance_ids

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  tags = var.resource_tags
}

module "ec2_instances" {
  source = "./modules/aws-instance"

  instance_count = var.instance_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc.private_subnets[*]
  security_group_ids = [module.app_security_group1.this_security_group_id, 
                        module.app_security_group2.this_security_group_id]

  tags = var.resource_tags
}

module "jumphost_instances" {
  source = "./modules/jumphost-instance"

  instance_count = var.jumphost_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc.public_subnets[*]
  security_group_ids = [module.jumphost_security_group.this_security_group_id]

  tags = var.resource_tags
}

