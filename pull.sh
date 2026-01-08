#!/usr/bin/env bash
set -e

# Load common variables and functions
source $(dirname "$0")/common.sh

# Parse arguments
parse_args "$@"

# Handle the case where there is no application and no environment
if [ ${#APPS[@]} -eq 0 ] && [ ${#ENVS[@]} -eq 0 ]; then
  vault_path="$VAULT_MOUNT/$PROJECT_SLUG"
  env_path=".env"
  echo -e "${BLUE_TEXT}Pulling from vault: $vault_path${RESET_TEXT}"
  vault kv get -format=json $vault_path |
    jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' >$env_path
fi

# Handle the case where there is no application
if [ ${#APPS[@]} -eq 0 ]; then
  for ENV in "${ENVS[@]}"; do
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$ENV"
    env_path=".env.$ENV"
    echo -e "${BLUE_TEXT}Pulling from vault: $vault_path${RESET_TEXT}"
    vault kv get -format=json $vault_path |
      jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' >$env_path
  done
fi

# Handle the case where there is no environment
if [ ${#ENVS[@]} -eq 0 ]; then
  for APP in "${APPS[@]}"; do
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$APP"
    env_path="apps/$APP/.env"
    echo -e "${BLUE_TEXT}Pulling from vault: $vault_path${RESET_TEXT}"
    vault kv get -format=json $vault_path |
      jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' >$env_path
  done
fi

# Handle the case where there is at least one application and one environment
for APP in "${APPS[@]}"; do
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  echo -e "${BOLD_TEXT}Pulling secrets for $APP${RESET_TEXT}"
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  for ENV in "${ENVS[@]}"; do
    echo
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$ENV/$APP"
    env_path="apps/$APP/.env.$ENV"
    echo -e "${BLUE_TEXT}Pulling from vault: $vault_path${RESET_TEXT}"
    vault kv get -format=json $vault_path |
      jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' >$env_path
  done
  echo
done
