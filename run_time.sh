#!/usr/bin/env bash

# exit if any command exits with non-zero status
set -e

GITHUB_TOKEN=$GITHUB_TOKEN
REPO=$GITHUB_REPOSITORY
TEMP_FILE="temp.json"

echo "Checking conclusion of the last executed run in \"$REPO\" repository:"

    curl \
        --silent \
        --location \
        --request GET \
        --header 'Accept: application/vnd.github.v4+json' \
        --header 'Content-Type: application/json' \
        --header "Authorization: token $GITHUB_TOKEN" \
        --header 'cache-control: no-cache' \
        "https://api.github.com/repos/${REPO}/actions/runs" > $TEMP_FILE

    CREATED_AT=$(jq -r '.workflow_runs[] | select(.run_number==19) | .created_at' $TEMP_FILE)
    echo "Check suite state: ${CREATED_AT}"
