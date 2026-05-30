#!/bin/bash
# scripts/setup-logging.sh
# ─────────────────────────────────────────────────────────────────────────────
# Week 9 Part 3 — Cloud Logging Queries
#
# Generates fresh log entries and queries them from the CLI.
# The log-based alert is created manually in the GCP Console.
#
# STEPS:
#   1. Generates 5 curl requests to create fresh logs
#   2. Queries Cloud Run logs with --freshness=7d
#   3. Queries audit logs for IAM changes from Part 1
# ─────────────────────────────────────────────────────────────────────────────

set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_NAME="cis410-flask-app"
REGION="us-central1"

echo "=================================================="
echo "  Week 9 Cloud Logging"
echo "  Project: ${PROJECT_ID}"
echo "=================================================="
echo ""

# ── Step 1: Generate fresh log entries ────────────────────────────────────────
echo ">>> STEP 1: Generating fresh log entries..."
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
  --region ${REGION} --format="value(status.url)")

echo "    Service URL: ${SERVICE_URL}"
echo "    Sending 5 requests..."

for i in {1..5}; do
  curl -s ${SERVICE_URL} > /dev/null
  echo "    Request ${i} sent"
done

echo "    Waiting 30 seconds for logs to appear..."
sleep 30
echo ""

# ── Step 2: Query Cloud Run logs ──────────────────────────────────────────────
echo ">>> STEP 2: Querying Cloud Run logs (last 7 days)"
echo "    Take Screenshot #3 of this output OR use the Console Logs Explorer"
echo ""

gcloud logging read \
  "resource.type=\"cloud_run_revision\" AND
   resource.labels.service_name=\"${SERVICE_NAME}\"" \
  --limit=20 \
  --freshness=7d \
  --format="table(timestamp,severity,textPayload)"

echo ""
echo ">>> Press Enter to query audit logs..."
read

# ── Step 3: Query IAM audit logs ──────────────────────────────────────────────
echo ">>> STEP 3: Querying audit logs for IAM changes from Part 1"
echo ""

gcloud logging read \
  "logName=\"projects/${PROJECT_ID}/logs/cloudaudit.googleapis.com%2Factivity\" AND
   protoPayload.methodName:\"SetIamPolicy\"" \
  --limit=10 \
  --freshness=7d \
  --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.methodName)"

echo ""
echo ">>> Now create the log-based alert manually in the Console:"
echo ""
echo "    1. Go to GCP Console → Logging → Logs Explorer"
echo "    2. Set time range to Last 2 weeks"
echo "    3. Paste this query:"
echo ""
echo '       resource.type="cloud_run_revision"'
echo '       resource.labels.service_name="'${SERVICE_NAME}'"'
echo '       severity>=WARNING'
echo ""
echo "    4. Click Run query"
echo "    5. Click Actions → Create log alert"
echo "    6. Alert name: cis410-flask-app-alert"
echo "    7. Notification frequency: 5 min"
echo "    8. Add your student email as notification channel"
echo "    9. Click Save"
echo ""
echo "    Take Screenshot #4 after the alert is created."
echo ""
echo ">>> Logging setup complete."
