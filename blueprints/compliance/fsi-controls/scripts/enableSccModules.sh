#!/bin/bash

ORGANIZATION_ID="262782368104"
BILLING_PROJECT_ID="dbs-validator-kcc-29ae"

ENABLED_DETECTORS=(
    SQL_NO_ROOT_PASSWORD
    SQL_WEAK_ROOT_PASSWORD
    VPC_FLOW_LOGS_SETTINGS_NOT_RECOMMENDED
)

echo "Enabling Security Health Analytics detectors for organization ${ORGANIZATION_ID}..."

for DETECTOR in "${ENABLED_DETECTORS[@]}"; do
  echo "Enabling detector: ${DETECTOR}..."
  gcloud alpha scc settings services modules enable \
    --organization="${ORGANIZATION_ID}" \
    --service="SECURITY_HEALTH_ANALYTICS" \
    --billing-project="${BILLING_PROJECT_ID}" \
    --module="${DETECTOR}"
done

echo "All specified detectors have been enabled."
