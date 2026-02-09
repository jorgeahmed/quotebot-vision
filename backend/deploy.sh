#!/bin/bash
set -e

# Configuration
SERVICE_NAME="quotebot-backend"
REGION="us-central1"

# Get current project ID
PROJECT_ID=$(gcloud config get-value project)

if [ -z "$PROJECT_ID" ]; then
  echo "Error: No Google Cloud Project selected. Run 'gcloud config set project YOUR_PROJECT_ID'"
  exit 1
fi

echo "🚀 Deploying $SERVICE_NAME to Project: $PROJECT_ID ($REGION)..."

# Enable Services (if not already)
echo "Ensuring APIs are enabled..."
gcloud services enable cloudbuild.googleapis.com run.googleapis.com aiplatform.googleapis.com firestore.googleapis.com storage.googleapis.com

# Build Container
echo "🏗️ Building Container..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME .

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=$PROJECT_ID

echo "✅ Deployment Complete!"
echo "Service URL is displayed above."
