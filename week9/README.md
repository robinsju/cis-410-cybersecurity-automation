# CIS 410 — Week 9 Code Package

## Files Included

```
scripts/
├── iam-audit.sh              ← Part 1: IAM audit + least-privilege fix
├── setup-secret-manager.sh   ← Part 2: Secret Manager setup
└── setup-logging.sh          ← Part 3: Cloud Logging queries + alert guide

docs/
└── week9-security-audit.md   ← Lab exercise template (fill in and commit)
```

## Before You Start

Confirm Week 8 is complete:
```bash
gcloud run services list --region us-central1
# cis410-flask-app must show ACTIVE

gcloud config get-value project
# must show your cis410-yourname project
```

## Quick Start

Copy the files into your existing repo:
```bash
cp -r scripts/ ~/cis-410-cybersecurity-automation/
cp -r docs/week9-security-audit.md ~/cis-410-cybersecurity-automation/docs/
cd ~/cis-410-cybersecurity-automation
```

Run each part in Cloud Shell:
```bash
# Part 1 — IAM Audit
bash scripts/iam-audit.sh

# Part 2 — Secret Manager
bash scripts/setup-secret-manager.sh

# Part 3 — Cloud Logging
bash scripts/setup-logging.sh
```

Or copy individual commands from each script directly into Cloud Shell.

## Screenshots Required

| # | What | Where |
|---|---|---|
| 1 | IAM policy output (before state) | Cloud Shell after running iam-audit.sh Step 1 |
| 2 | flask-app-secret listed | GCP Console → Secret Manager |
| 3 | Cloud Run logs visible | GCP Console → Logging → Logs Explorer |
| 4 | Alert policy created | GCP Console → Monitoring → Alerting |
| 5 | Billing budget listed | GCP Console → Billing → Budgets & alerts |

## Commit Your Work

```bash
git add docs/week9-security-audit.md
git commit -m "Week 9: IAM audit + Secret Manager + logging config"
git push origin main
```

## Common Errors

| Error | Fix |
|---|---|
| `Permission denied` removing run.admin | Role may already have been removed — check with `gcloud projects get-iam-policy` first |
| `Permission denied on secret` for Cloud Run | The Compute SA also needs secretAccessor — run Step 3b in setup-secret-manager.sh |
| No logs in Logs Explorer | Change time range to Last 2 weeks, send curl requests first |
| `Actions → Create log alert` not visible | Widen browser window or zoom out — button may be hidden |
