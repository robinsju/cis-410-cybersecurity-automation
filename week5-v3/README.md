# CIS 410 — Week 5 Code Package

## Contents

### Fixed Application (copy into your repo's `app/`)
- `app/app.py` — CorpDirectory with all 4 vulnerabilities fixed
- `app/requirements.txt` — clean dependencies
- `app/templates/index.html` — secure version with fix summary panel
- `app/templates/search.html` — parameterized query display

### Fixed Dockerfile (replaces `Dockerfile` in repo root)
- `Dockerfile` — python:3.11-slim, non-root user, correct layer order

### Workflow files (copy into `.github/workflows/`)
- `scan.yml` — Snyk security gate on all pull requests (no installation needed)
- `dast-scan.yml` — OWASP ZAP dynamic scan, manual trigger

## Required GitHub Secret

Before scan.yml will work you need one new secret:

| Secret     | Value              | How to get it                                    |
|------------|--------------------|--------------------------------------------------|
| SNYK_TOKEN | Your Snyk API token | snyk.io → Account Settings → Auth Token (free) |

Add it: GitHub repo → Settings → Secrets and variables → Actions → New repository secret

## Week 5 Lab Flow

1. Copy scan.yml and dast-scan.yml into .github/workflows/  
2. Add SNYK_TOKEN secret  
3. Commit and push  
4. Create a feature branch → open PR (vulnerable app is still in app/)  
5. Snyk blocks the PR — screenshot the failure  
6. Copy fixed app/ and Dockerfile from this package  
7. Commit to the same branch → Snyk passes — screenshot clean scan  
8. Merge PR → deploy-dev.yml auto-deploys to dev  
9. Run dast-scan.yml against dev → ZAP confirms fix  
10. Promote to staging → run dast-scan.yml with staging target  
11. Promote to production
