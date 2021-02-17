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

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  cidr = var.vpc1_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private1_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public1_subnet_cidr_blocks,  0, var.public_subnet_count)

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.resource_tags
}

module "jumphost_security_group1" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "jumphost1-ssh-sg-mdwlab-dev"
  description = "Security group for jumphost in public subnet"
  vpc_id      = module.vpc1.vpc_id

  ingress_cidr_blocks = var.jumphost_cidr_blocks
  tags = var.resource_tags
}

module "app_security_group11" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "3.17.0"

  name        = "app1-lb-sg-mdwlab-dev"
  description = "Security group for web-servers with HTTP ports open within Load Balancer"
  vpc_id      = module.vpc1.vpc_id
  ingress_cidr_blocks = module.vpc1.public_subnets_cidr_blocks

  tags = var.resource_tags
}

module "app_security_group12" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "app1-ssh-sg-mdwlab-dev"
  description = "Security group for webservers with SSH ports"
  vpc_id      = module.vpc1.vpc_id

  ingress_cidr_blocks = module.vpc1.public_subnets_cidr_blocks
  tags = var.resource_tags
}


module "ec2_instances1" {
  source = "./modules/aws-instance"

  instance_count = var.instance_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc1.private_subnets[*]
  security_group_ids = [module.app_security_group11.this_security_group_id,
                        module.app_security_group12.this_security_group_id]

  tags = var.resource_tags
}

module "jumphost_instances1" {
  source = "./modules/jumphost-instance"

  instance_count = var.jumphost_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc1.public_subnets[*]
  security_group_ids = [module.jumphost_security_group1.this_security_group_id]

  tags = var.resource_tags
}



module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  cidr = var.vpc2_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private2_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public2_subnet_cidr_blocks,  0, var.public_subnet_count)

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.resource_tags
}

module "jumphost_security_group2" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "jumphost2-ssh-sg-mdwlab-dev"
  description = "Security group for jumphost in public subnet"
  vpc_id      = module.vpc2.vpc_id

  ingress_cidr_blocks = var.jumphost_cidr_blocks
  tags = var.resource_tags
}

module "app_security_group21" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "3.17.0"

  name        = "app2-lb-sg-mdwlab-dev"
  description = "Security group for web-servers with HTTP ports open within Load Balancer"
  vpc_id      = module.vpc2.vpc_id
  ingress_cidr_blocks = module.vpc2.public_subnets_cidr_blocks

  tags = var.resource_tags
}

module "app_security_group22" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.17.0"

  name        = "app2-ssh-sg-mdwlab-dev"
  description = "Security group for webservers with SSH ports"
  vpc_id      = module.vpc2.vpc_id

  ingress_cidr_blocks = module.vpc2.public_subnets_cidr_blocks
  tags = var.resource_tags
}


module "ec2_instances2" {
  source = "./modules/aws-instance"

  instance_count = var.instance_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc2.private_subnets[*]
  security_group_ids = [module.app_security_group21.this_security_group_id,
                        module.app_security_group22.this_security_group_id]

  tags = var.resource_tags
}

module "jumphost_instances2" {
  source = "./modules/jumphost-instance"

  instance_count = var.jumphost_count
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc2.public_subnets[*]
  security_group_ids = [module.jumphost_security_group2.this_security_group_id]

  tags = var.resource_tags
}
