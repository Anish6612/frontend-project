output "cloudfront_url" {
  description = "Public CloudFront URL for the random page."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "Needed for invalidations in both pipelines."
  value       = aws_cloudfront_distribution.site.id
}

output "site_bucket" {
  description = "S3 site bucket (private, OAC only)."
  value       = aws_s3_bucket.site.bucket
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "github_actions_role_arn" {
  description = "Put this in GitHub Actions secrets as AWS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}

output "codepipeline_name" {
  value = aws_codepipeline.frontend.name
}

output "codestar_connection_arn" {
  description = "Approve this connection once in console (PENDING -> AVAILABLE)."
  value       = aws_codestarconnections_connection.github.arn
}

output "github_repo_url" {
  value = "https://github.com/${var.github_owner}/${var.github_repo}"
}
