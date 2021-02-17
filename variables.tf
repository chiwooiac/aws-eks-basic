variable "aws_credentials_file" {
  type        = string
  description = "describe a path to locate a credentials from access aws cli"
  default     = "$HOME/.aws/credentials"
}

variable "aws_profile" {
  type        = string
  description = "describe a specifc profile to access a aws cli"
  default     = "dxterra"
}


variable "project_name" {
  description = "project name is usally account's project name or platform name"
  type = string
  default = "dx-basic"
}

variable "aws_region" {
  type        = string
  description = "describe default region to create a resource from aws"
  default     = "ap-northeast-2"
}

variable "region_alias" {
  description = "region alias or AWS"
  type = string
  default = "an2"
}

variable "env_name" {
  description = "Runtime Environment such as develop, stage, production"
  type = string
  default = "Testbed"
}

variable "env_alias" {
  description = "Runtime Environment such as develop, stage, production"
  type = string
  default = "t"
}

variable "owner" {
  description = "project owner"
  type = string
  default = "devdataopsx_bgk@bespinglobal.com"
}

variable "team_name" {
  description = "team name of DevOps"
  type = string
  default = "Devops Transformation"
}

variable "team_alias" {
  description = "team name of Devops Transformation"
  type = string
  default = "dx"
}

variable "cost_center" {
  description = "CostCenter"
  type = string
  default = "827519537363"
}

locals {
  category_name = "${var.team_alias}-${var.region_alias}"

  resource_prefix = "${var.project_name}-${var.region_alias}-${var.env_alias}"

  extra_tags = {
    "Owner" = var.owner
    "Team" = var.team_alias
    "CostCenter" = var.cost_center
  }

  extra_asg_tags = [
    {
      key = "Env"
      value = var.env_name
      propagate_at_launch = true
    },
    {
      key = "Owner"
      value = var.owner
      propagate_at_launch = true
    },
    {
      key = "Proejct"
      value = var.project_name
      propagate_at_launch = true
    },
    {
      key = "Team"
      value = var.team_alias
      propagate_at_launch = true
    }
  ]

}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "827519537363"
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::827519537363:user/seonbo.shim@bespinglobal.com"
      username = "seonbo.shim@bespinglobal.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::827519537363:user/youngkeun.kim@bespinglobal.com"
      username = "youngkeun.kim@bespinglobal.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::827519537363:user/chiseok.song@bespinglobal.com"
      username = "chiseok.song@bespinglobal.com"
      groups   = ["system:masters"]
    },
  ]
}