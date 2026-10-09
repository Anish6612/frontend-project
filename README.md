# Frontend Project — S3 + CloudFront with TWO pipelines (learning)

Account: `872857212221` / user `aws-learning-user` / region `us-east-1`
Repo: https://github.com/Anish6612/frontend-project

You learn: how a `frontend/` folder becomes a public CloudFront URL via IaC + CI/CD.

```
GitHub main
   ├─(A) GitHub Actions (OIDC, no keys) ──sync──> S3 site bucket ──origin(OAC)──> CloudFront ──> https://xxxx.cloudfront.net
   └─(B) CodeStar Connection ──> CodePipeline ──> CodeBuild (buildspec.yml) ──sync+invalidate──> same S3 + CloudFront
Terraform creates: S3 site (private) + CloudFront OAC distro + artifacts bucket + IAM OIDC role + CodePipeline/CodeBuild/Connection
```

## DevOps practices used
- IaC: versioned Terraform (`>=1.9`, AWS provider `~>6.0`), `random_pet` for unique buckets, `default_tags`.
- Least privilege IAM: separate roles for GHA, CodeBuild, CodePipeline. No long-lived keys for GHA (OIDC `token.actions.githubusercontent.com`).
- Private S3 + OAC (not legacy OAI). Versioning + SSE + `BucketOwnerEnforced` + 30-day artifact lifecycle.
- Pipeline env injection: `SITE_BUCKET`/`DISTRIBUTION_ID` passed as CodeBuild env vars, GHA via repo Variables — never hardcoded.
- `plan` before `apply`, remote-state snippet in `versions.tf` for prod.

## Latest AWS refs (2026)
- `aws_cloudfront_origin_access_control` + `origin_access_control_id` (OAC, SigV4 always)
- `aws_codestarconnections_connection` (`provider_type="GitHub"`, starts PENDING)
- `aws_codepipeline` with `CodeStarSourceConnection` + `aws_codebuild_project` (`CODEPIPELINE` type)
- `aws_iam_openid_connect_provider` + `data tls_certificate` for GitHub OIDC
- Managed `cache_policy_id = 658327ea-...` (CachingOptimized)

## 1) Deploy infra
```powershell
cd terraform
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
# note outputs: cloudfront_url, site_bucket, distribution_id, github_actions_role_arn, codestar_connection_arn
```

Initial `apply` creates empty buckets + distro (no files yet) — CloudFront takes ~5 min to deploy.

Upload first version manually so URL works before pipelines run:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
aws s3 sync ../frontend s3://<site_bucket>/ --delete
aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
```

## 2) Enable pipeline A — GitHub Actions (automated)
In GitHub repo → Settings → Secrets and variables → Actions → Variables → New:
- `AWS_REGION` = `us-east-1`
- `S3_BUCKET` = terraform output `site_bucket`
- `DISTRIBUTION_ID` = terraform output
- `AWS_ROLE_ARN` = terraform output `github_actions_role_arn`

Then push to `main` touching `frontend/` — workflow `.github/workflows/deploy.yml` syncs + invalidates. No console clicks.

## 3) Enable pipeline B — CodePipeline (one manual click)
Terraform creates `aws_codestarconnections_connection` in `PENDING`. You MUST:
AWS Console → Developer Tools → Connections → select `frontend-project-github` → Update pending connection → authorize GitHub → choose `Anish6612/frontend-project`.

Then: either push to `main` (auto-trigger) or Console → CodePipeline → Release change. CodeBuild uses `buildspec.yml` (env vars injected by Terraform).

## 4) Learn loop
1. Edit `frontend/app.js` (e.g. add tip), `git commit`, `git push`.
2. Watch BOTH: Actions tab + CodePipeline executions + CodeBuild logs (`/aws/codebuild/frontend-project-deploy`).
3. Open `terraform output cloudfront_url` — hard refresh. Check invalidation IDs.
4. `aws s3 ls s3://<site>/ --recursive` vs git — same files.

## Costs / cleanup
- S3 + CloudFront + pipelines ~ cents for learning. CloudWatch logs 30-day retention.
- Destroy: `terraform destroy`. Empty buckets via `force_destroy=true` (learning only).

## Security — READ THIS
- The GitHub PAT you pasted in chat is now exposed. Rotate it NOW: GitHub → Settings → Developer settings → Tokens → Revoke `ghp_...` → create new with `repo` scope only, expiry 7-30 days.
- Never commit tokens: this repo has no secrets; pipelines use OIDC (GHA) and IAM roles (CodeBuild). `*.tfvars` is gitignored.
