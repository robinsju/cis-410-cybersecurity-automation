# CIS 410 — Week 8 Code Package

## Directory Structure

```
.github/
└── workflows/
    └── deploy-cloudrun.yml       ← build-push-deploy OIDC workflow

terraform/
└── week8/
    ├── main.tf                   ← Cloud Run service + public IAM + remote_state
    ├── variables.tf              ← project_id, region, container_image
    ├── outputs.tf                ← service_url, service_name, latest_revision
    └── terraform.tfvars.example  ← copy → terraform.tfvars and fill in values

docs/
└── week8-comparison.md           ← lab exercise template (fill in and commit)
```

## Before You Start

1. Confirm Week 7 is complete:
   ```bash
   gcloud compute networks list          # cis410-vpc must exist
   gcloud storage ls                     # tfstate bucket must exist
   cd terraform/week7 && terraform output  # vpc_name and subnet_name must print
   ```

2. Note the exact output names from `terraform output` in Week 7.
   Update the `data.terraform_remote_state.week7.outputs.XXX` references
   in `terraform/week8/main.tf` if they differ.

## Quick Start (Cloud Shell)

```bash
# 1. Copy files into your repo
cp -r terraform/ ~/cis-410-cybersecurity-automation/
cp -r .github/   ~/cis-410-cybersecurity-automation/
cp -r docs/      ~/cis-410-cybersecurity-automation/

# 2. Navigate to your repo
cd ~/cis-410-cybersecurity-automation

# 3. Confirm Cloud Shell is on the right project
gcloud config list   # account and project must be correct
gcloud config set project cis410-yourname-xxxx   # if wrong

# 4. Enable required APIs
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# 5. Create Artifact Registry repository
gcloud artifacts repositories create cis410-app \
  --repository-format=docker \
  --location=us-central1

# 6. Add Cloud Run permissions to the service account
SA_EMAIL="cis410-deploy-sa@$(gcloud config get-value project).iam.gserviceaccount.com"
PROJECT_ID=$(gcloud config get-value project)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" --role="roles/run.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" --role="roles/artifactregistry.writer"

# 7. Set image variables and build
export PROJECT_ID=$(gcloud config get-value project)
export IMAGE_TAG=$(git rev-parse --short HEAD)
export REGISTRY=us-central1-docker.pkg.dev
export IMAGE_PATH=${REGISTRY}/${PROJECT_ID}/cis410-app/flask-app:${IMAGE_TAG}
echo $IMAGE_PATH   # write this down

gcloud builds submit --tag ${IMAGE_PATH} .

# 8. Update backend bucket name in terraform/week8/main.tf
#    Replace cis410-yourname-xxxx-tfstate with your actual bucket name (in TWO places)

# 9. Create terraform.tfvars
cd terraform/week8
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
#   project_id      = "your-actual-project-id"
#   container_image = "paste IMAGE_PATH value from step 7"

# 10. Deploy
terraform init
terraform plan    # should show: 2 to add
terraform apply   # type yes

# 11. Test the service
terraform output service_url
curl $(terraform output -raw service_url)

# 12. Commit (NOT terraform.tfvars)
cd ~/cis-410-cybersecurity-automation
git add terraform/week8/main.tf terraform/week8/variables.tf
git add terraform/week8/outputs.tf terraform/week8/.terraform.lock.hcl
git add .github/workflows/deploy-cloudrun.yml
git add docs/week8-comparison.md
git status   # confirm terraform.tfvars is NOT staged
git commit -m "Week 8: Cloud Run + Artifact Registry + CI/CD pipeline"
git push origin main
```

## Common Errors

| Error | Fix |
|---|---|
| `outputs is object with no attributes` | Run `terraform output` in terraform/week7/ to check exact output names. Update references in main.tf. |
| `PERMISSION_DENIED on gcloud builds submit` | Run `gcloud config set project YOUR_PROJECT_ID` then re-export all variables |
| `dial tcp 443: connection refused` | Cloud Shell network timeout. Re-authenticate: `gcloud auth configure-docker us-central1-docker.pkg.dev` and retry |
| `403 on Cloud Run URL` | Public IAM binding not applied. Check `google_cloud_run_v2_service_iam_member.public_access` exists in terraform apply output |
| `Cloud Run API not enabled` | `gcloud services enable run.googleapis.com` |

## GitHub Variables Required

These must be set in GitHub → Settings → Secrets and variables → Variables:

| Variable | Value |
|---|---|
| WIF_PROVIDER | Full Workload Identity Provider path (from Week 7) |
| SA_EMAIL | cis410-deploy-sa@PROJECT_ID.iam.gserviceaccount.com |
| TF_VAR_PROJECT_ID | Your GCP project ID |
