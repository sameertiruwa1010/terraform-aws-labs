terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_group" "terraform_admin_group" {
  name = "terraform-admin-group"
}

resource "aws_iam_user" "terraform_user" {
  name = "terraform-user"
}

resource "aws_iam_user_group_membership" "user_group_attach" {
  user = aws_iam_user.terraform_user.name

  groups = [
    aws_iam_group.terraform_admin_group.name
  ]
}

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.terraform_admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}