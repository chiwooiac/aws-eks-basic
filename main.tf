
locals {
  cluster_name = "${local.resource_prefix}-eks" # "test-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "wg_gateway_sg" {
  name_prefix = "${local.resource_prefix}-wg-gateway"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "wg_management_sg" {
  name_prefix = "${local.resource_prefix}-wg-management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "wg_all_sg" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 2.58.0"

  name                 = "test-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "14.0.0"

  # 현재 1.19 k8s 클러스터를 AWS EKS 에서 지원하지 않음 (정확히는 AMI 가 존재하지 않으므로 AMI 를 커스텀 제작 이후에 진행 할 수 있음)
  cluster_version = "1.18"
  cluster_name    = local.cluster_name

  subnets         = module.vpc.private_subnets

  tags = {
    Team        = var.team_alias
    CostCenter  = var.cost_center
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.env_name
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "wg-gateway"
      instance_type                 = "t3.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.wg_gateway_sg.id]
    },
    {
      name                          = "wg-management"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.wg_management_sg.id]
      asg_desired_capacity          = 1
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.wg_all_sg.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts

}


module "kubernetes-config" {
  source            = "./kubernetes"
  cluster_ca_cert   = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
  k8s_node_role_arn = list(data.aws_eks_cluster.cluster.role_arn)
  cluster_name      = data.aws_eks_cluster.cluster.id  # creates dependency on cluster creation
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

/*
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
}
*/

data "aws_availability_zones" "available" {
}
