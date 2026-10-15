#!/usr/bin/env bash
# One-time setup of the Google Cloud resources that the
# GitHub workflow deploys to. Safe to re-run: anything that
# already exists is left alone.
#
# Usage:
#   PROJECT_ID=my-project ./scripts/gcp-setup.sh
#
# Optional overrides: REGION, SERVICE, AR_REPO, GITHUB_REPO
set -euo pipefail

PROJECT_ID=${PROJECT_ID:?set PROJECT_ID to your GCP project id}
REGION=${REGION:-us-central1}
SERVICE=${SERVICE:-http-endpoint}
AR_REPO=${AR_REPO:-http-endpoint}
GITHUB_REPO=${GITHUB_REPO:-bincent0929/vincent-roberson-liatrio-apprentice-interview-exercise}

POOL=github
PROVIDER=github-repo
DEPLOY_SA=github-deployer@${PROJECT_ID}.iam.gserviceaccount.com
RUNTIME_SA=${SERVICE}-runtime@${PROJECT_ID}.iam.gserviceaccount.com

gcloud config set project "$PROJECT_ID"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')

echo "==> Enabling APIs"
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com

echo "==> Artifact Registry repo (where the workflow pushes the image)"
gcloud artifacts repositories describe "$AR_REPO" --location="$REGION" >/dev/null 2>&1 ||
  gcloud artifacts repositories create "$AR_REPO" \
    --repository-format=docker \
    --location="$REGION" \
    --description="Images built by GitHub Actions"

# keep the 10 most recent images so the repo doesn't grow forever
CLEANUP_POLICY=$(mktemp)
cat > "$CLEANUP_POLICY" <<'EOF'
[
  {"name": "keep-recent", "action": {"type": "Keep"}, "mostRecentVersions": {"keepCount": 10}},
  {"name": "delete-old", "action": {"type": "Delete"}, "condition": {"olderThan": "30d"}}
]
EOF
gcloud artifacts repositories set-cleanup-policies "$AR_REPO" \
  --location="$REGION" --policy="$CLEANUP_POLICY" --no-dry-run
rm -f "$CLEANUP_POLICY"

echo "==> Service accounts"
# runtime identity for the container; it needs no permissions
gcloud iam service-accounts describe "$RUNTIME_SA" >/dev/null 2>&1 ||
  gcloud iam service-accounts create "${SERVICE}-runtime" \
    --display-name="Cloud Run runtime for ${SERVICE}"

# identity GitHub Actions uses to push images and deploy
gcloud iam service-accounts describe "$DEPLOY_SA" >/dev/null 2>&1 ||
  gcloud iam service-accounts create github-deployer \
    --display-name="GitHub Actions deployer"

gcloud artifacts repositories add-iam-policy-binding "$AR_REPO" \
  --location="$REGION" \
  --member="serviceAccount:${DEPLOY_SA}" \
  --role=roles/artifactregistry.writer >/dev/null

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${DEPLOY_SA}" \
  --role=roles/run.admin --condition=None >/dev/null

# lets the deployer launch the service as the runtime account
gcloud iam service-accounts add-iam-policy-binding "$RUNTIME_SA" \
  --member="serviceAccount:${DEPLOY_SA}" \
  --role=roles/iam.serviceAccountUser >/dev/null

echo "==> Workload Identity Federation (keyless auth from GitHub)"
gcloud iam workload-identity-pools describe "$POOL" --location=global >/dev/null 2>&1 ||
  gcloud iam workload-identity-pools create "$POOL" \
    --location=global \
    --display-name="GitHub Actions"

# the attribute condition means only this repo can get tokens
gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --location=global --workload-identity-pool="$POOL" >/dev/null 2>&1 ||
  gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
    --location=global \
    --workload-identity-pool="$POOL" \
    --display-name="GitHub repo" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
    --attribute-condition="assertion.repository=='${GITHUB_REPO}'"

gcloud iam service-accounts add-iam-policy-binding "$DEPLOY_SA" \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL}/attribute.repository/${GITHUB_REPO}" >/dev/null

WIF_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL}/providers/${PROVIDER}"

cat <<EOF

Done. Add these as GitHub repository *variables*
(Settings > Secrets and variables > Actions > Variables):

  GCP_PROJECT_ID    = ${PROJECT_ID}
  GCP_REGION        = ${REGION}
  GCP_AR_REPO       = ${AR_REPO}
  GCP_SERVICE       = ${SERVICE}
  GCP_WIF_PROVIDER  = ${WIF_PROVIDER}
  GCP_DEPLOY_SA     = ${DEPLOY_SA}
  GCP_RUNTIME_SA    = ${RUNTIME_SA}

The next push to main builds, tests, and deploys the image to Cloud Run.
Get the URL afterwards with:

  gcloud run services describe ${SERVICE} --region ${REGION} --format='value(status.url)'
EOF
