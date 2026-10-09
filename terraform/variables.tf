variable "aws_region" {
  description = "AWS region. us-east-1 is used because CloudFront + learning account is there."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix for all resource names and tags."
  type        = string
  default     = "frontend-project"
}

variable "github_owner" {
  description = "GitHub org or user that owns the frontend repo."
  type        = string
  default     = "Anish6612"
}

variable "github_repo" {
  description = "GitHub repo name used as pipeline source."
  type        = string
  default     = "frontend-project"
}

variable "github_branch" {
  description = "Branch the pipeline watches."
  type        = string
  default     = "main"
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_100 = cheapest (US/EU)."
  type        = string
  default     = "PriceClass_100"
}

variable "codebuild_image" {
  description = "Latest AWS-managed CodeBuild image (2026)."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "codestar_connection_arn" {
  description = "Existing CodeConnections ARN (Status Available). When set, Terraform reuses it instead of creating a new connection — avoids needing codeconnections:CreateConnection."
  type        = string
  default     = ""
}
