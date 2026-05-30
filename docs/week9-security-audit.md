# Week 9 Security Audit — cis410-deploy-sa
**Project:** cis410-julia
**Date:** May 29, 2026
**Auditor:** Julia
---
## 1. IAM Audit Results
### Before — Week 8 Configuration (over-permissioned)
| Role | Scope | Problem |
|---|---|---|
| roles/run.admin | Project | Overly broad — grants ability to delete services and modify IAM, not just deploy |
| roles/storage.admin | Project | Overly broad — grants access to ALL GCS buckets in the project |
| roles/artifactregistry.writer | Project | Acceptable — scoped to push images only |
| roles/viewer | Project | Acceptable — read-only project metadata |
| roles/iam.serviceAccountUser | Compute SA | Required — needed to act as Compute Engine default SA |
### After — Week 9 Least-Privilege Fix
| Role | Scope | Why Sufficient |
|---|---|---|
| roles/run.developer | Project | Deploy only — cannot delete services or modify IAM |
| roles/storage.admin | tfstate bucket only | Scoped to one bucket — not all storage |
| roles/artifactregistry.writer | Project | Unchanged — push images only |
| roles/viewer | Project | Unchanged — read project metadata |
| roles/iam.serviceAccountUser | Compute SA | Unchanged — required for Cloud Run deployment |
---
## 2. Secret Manager Migration
- **Secret created:** `flask-app-secret`
- **Replication:** automatic
- **Access granted to:** `cis410-deploy-sa` — roles/secretmanager.secretAccessor on this secret only
- **Access granted to:** `PROJECT_NUMBER-compute@developer.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only (required for Cloud Run runtime access)
- **Cloud Run update:** APP_SECRET environment variable mounted from Secret Manager at runtime
---
## 3. Monitoring Configuration
- **Log-based alert:** `cis410-flask-app-alert` — fires on severity>=WARNING for cis410-flask-app
- **Notification channel:** robins69jul@gmail.com
- **Billing budget:** `cis410-monthly-budget` — $20 limit, alerts at 50% / 90% / 100%
---
## 4. Reflection
**Q1: Why is roles/run.admin inappropriate for a CI/CD pipeline service account?**
The run.admin role violates the principle of least privilege because it gives a pipeline deployment account far too much power, such as the ability to completely delete production web services or alter critical IAM security policies. A standard CI/CD pipeline only needs permissions to build and deploy new application revisions, which is fully covered under the restricted run.developer role.
---
**Q2: What is the security difference between storing a secret in GitHub Secrets vs. Google Secret Manager?**
GitHub Secrets are static environment variables that get injected directly into your pipeline at build time, which leaves them vulnerable to being exposed in container history or workflow log files. Google Secret Manager securely isolates the secret inside GCP infrastructure, meaning the live app container safely requests the value over an encrypted internal API call at runtime without it ever touching your source code repo.
---
**Q3: A coworker says "I will clean up IAM permissions after the project launches. For now I need everything to work fast." What is the risk of this approach?**
The main risk is that temporary over-permissioned admin rights almost always become permanent security vulnerabilities due to shifting development priorities after a project goes live. Leaving wide-open admin privileges active creates a dangerous attack surface where a single compromised pipeline credential could allow a hacker to breach and destroy your entire cloud infrastructure.
