#!/bin/bash

VAULT_ADDR='http://127.0.0.1:8200'
SECRET_PATH='kv/skills-utilization'
ENV_FILE="$(dirname "$0")/.env"

export VAULT_ADDR

echo "Retrieving secrets from Vault..."

SECRETS=$(vault kv get -format=json "$SECRET_PATH")

if [ $? -ne 0 ]; then
    echo "Failed to retrieve secrets from Vault."
    exit 1
fi

echo "Saving secrets to $ENV_FILE..."

echo "$SECRETS" | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"' > "$ENV_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to save secrets to $ENV_FILE."
    exit 1
fi

echo "Secrets successfully loaded into .env"

echo "Starting Docker Compose..."

docker compose up -d --no-build

if [ $? -ne 0 ]; then
    echo "Docker Compose failed."
    exit 1
fi

echo "Application started successfully."
