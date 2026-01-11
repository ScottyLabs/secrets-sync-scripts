#!/usr/bin/env bash
set -e

# Load common variables and functions
source $(dirname "$0")/common.sh

# Parse arguments
parse_args "$@"

# Handle the case where there is no application and no environment
if [ ${#APPS[@]} -eq 0 ] && [ ${#ENVS[@]} -eq 0 ]; then
  vault_path="$PROJECT"
  echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
  env_path=".env"
  cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  exit 0
fi

# Handle the case where there is no application
if [ ${#APPS[@]} -eq 0 ]; then
  for ENV in "${ENVS[@]}"; do
    vault_path="$PROJECT/$ENV"
    env_path=".env.$ENV"
    if [ "$ENV" == $APPLICANTS_ENV_NAME ]; then
      env_path=".env"
    fi
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
  exit 0
fi

# Handle the case where there is no environment
if [ ${#ENVS[@]} -eq 0 ]; then
  for APP in "${APPS[@]}"; do
    vault_path="$PROJECT/$APP"
    env_path="apps/$APP/.env"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
  exit 0
fi

# Handle the case where there is at least one application and one environment
for APP in "${APPS[@]}"; do
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  echo -e "${BOLD_TEXT}Pushing secrets for $APP${RESET_TEXT}"
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  for ENV in "${ENVS[@]}"; do
    echo
    vault_path="$PROJECT/$ENV/$APP"
    env_path="apps/$APP/.env.$ENV"
    if [ "$ENV" == $APPLICANTS_ENV_NAME ]; then
      env_path="apps/$APP/.env"
    fi
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
  echo
done
