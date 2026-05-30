#!/bin/bash
# scripts/setup-secret-manager.sh
# ─────────────────────────────────────────────────────────────────────────────
# Week 9 Part 2 — Secret Manager Setup
#
# Creates a secret, grants access to both the deploy SA and the Compute SA,
# and mounts the secret into the Cloud Run service.
#
# WHY TWO SERVICE ACCOUNTS?
#   cis410-deploy-sa:    deploys the Cloud Run service (CI/CD pipeline)
#   PROJECT_NUMBER-compute@...: runs the Cloud Run containers at runtime
#
#   Both need secretAccessor. Without the Compute SA binding Cloud Run
#   fails with: Permission denied on secret for Revision service account.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── Variables ─────────────────────────────────────────────────────────────────
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="cis410-deploy-sa@${PROJECT_ID}.iam.gserviceaccount.com"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
SECRET_NAME="flask-app-secret"
SERVICE_NAME="cis410-flask-app"
REGION="us-central1"

echo "=================================================="
echo "  Week 9 Secret Manager Setup"
echo "  Project:    ${PROJECT_ID}"
echo "  Secret:     ${SECRET_NAME}"
echo "=================================================="
echo ""

# ── Step 1: Enable API ────────────────────────────────────────────────────────
echo ">>> STEP 1: Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com
echo "    Done."
echo ""

# ── Step 2: Create the secret ─────────────────────────────────────────────────
echo ">>> STEP 2: Creating secret '${SECRET_NAME}'..."
echo -n "my-super-secret-value" | gcloud secrets create ${SECRET_NAME} \
  --data-file=- \
  --replication-policy="automatic"

echo "    Verifying..."
gcloud secrets list | grep ${SECRET_NAME}
echo ""
echo "    Take Screenshot #2 — GCP Console → Secret Manager"
echo ""
echo ">>> Press Enter to continue to Step 3 (grant access)..."
read

# ── Step 3: Grant secretAccessor to deploy SA ─────────────────────────────────
echo ">>> STEP 3a: Granting secretAccessor to cis410-deploy-sa..."
gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/secretmanager.secretAccessor"
echo "    Done."
echo ""

# ── Step 4: Grant secretAccessor to Compute SA ────────────────────────────────
echo ">>> STEP 3b: Granting secretAccessor to Compute Engine default SA..."
echo "    This is required for Cloud Run containers to access the secret at runtime."
gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/secretmanager.secretAccessor"
echo "    Done."
echo ""

# Verify both bindings
echo "    Verifying IAM policy on secret:"
gcloud secrets get-iam-policy ${SECRET_NAME}
echo ""
echo ">>> Press Enter to continue to Step 4 (mount in Cloud Run)..."
read

# ── Step 5: Mount secret in Cloud Run ─────────────────────────────────────────
echo ">>> STEP 4: Mounting secret in Cloud Run as APP_SECRET env var..."
gcloud run services update ${SERVICE_NAME} \
  --region ${REGION} \
  --update-secrets="APP_SECRET=${SECRET_NAME}:latest"

echo ""
echo "    Verifying env var is mounted:"
gcloud run services describe ${SERVICE_NAME} \
  --region ${REGION} \
  --format="yaml(spec.template.spec.containers[0].env)"

echo ""
echo ">>> Secret Manager setup complete."
