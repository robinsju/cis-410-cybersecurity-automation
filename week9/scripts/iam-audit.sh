#!/bin/bash
# scripts/iam-audit.sh
# ─────────────────────────────────────────────────────────────────────────────
# Week 9 Part 1 — IAM Audit and Least-Privilege Fix
#
# Run each section one at a time. Read the output before continuing.
# All commands run in Cloud Shell.
#
# USAGE:
#   bash scripts/iam-audit.sh
#
# Or copy and paste each section individually into Cloud Shell.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── Variables ─────────────────────────────────────────────────────────────────
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="cis410-deploy-sa@${PROJECT_ID}.iam.gserviceaccount.com"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
TFSTATE_BUCKET="gs://${PROJECT_ID}-tfstate"

echo "=================================================="
echo "  Week 9 IAM Audit"
echo "  Project:    ${PROJECT_ID}"
echo "  SA Email:   ${SA_EMAIL}"
echo "  Compute SA: ${COMPUTE_SA}"
echo "=================================================="
echo ""

# ── Step 1: Audit current IAM bindings ───────────────────────────────────────
echo ">>> STEP 1: Current IAM bindings for cis410-deploy-sa"
echo "    Take Screenshot #1 of this output"
echo ""

gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  --filter="bindings.members:${SA_EMAIL}"

echo ""
echo ">>> Press Enter to continue to Step 2 (remove run.admin)..."
read

# ── Step 2: Replace run.admin with run.developer ─────────────────────────────
echo ">>> STEP 2: Replacing roles/run.admin with roles/run.developer"
echo ""

echo "    Removing roles/run.admin..."
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/run.admin"

echo "    Adding roles/run.developer..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/run.developer"

echo "    Done. roles/run.developer replaces roles/run.admin."
echo ""
echo ">>> Press Enter to continue to Step 3 (fix storage.admin)..."
read

# ── Step 3: Replace project-level storage.admin with bucket-level ─────────────
echo ">>> STEP 3: Scoping storage.admin to tfstate bucket only"
echo ""

echo "    Removing project-level roles/storage.admin..."
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"

echo "    Adding bucket-level storage.admin on ${TFSTATE_BUCKET}..."
gcloud storage buckets add-iam-policy-binding ${TFSTATE_BUCKET} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"

echo "    Done. storage.admin now scoped to tfstate bucket only."
echo ""
echo ">>> Press Enter to verify the final policy..."
read

# ── Step 4: Verify ────────────────────────────────────────────────────────────
echo ">>> STEP 4: Verifying final project-level IAM policy"
echo "    Expected: run.developer, artifactregistry.writer, viewer"
echo "    NOT expected: run.admin, storage.admin (at project level)"
echo ""

gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  --filter="bindings.members:${SA_EMAIL}"

echo ""
echo ">>> IAM audit complete."
