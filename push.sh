#!/usr/bin/env bash
set -e

# Load the configuration
source ./config.sh

# Parse arguments
parse_args "$0" "push" "$@"

# Handle the case where there is no application and no environment
if [ ${#APPS[@]} -eq 0 ] && [ ${#ENVS[@]} -eq 0 ]; then
  vault_path="$PROJECT_SLUG"
  echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
  env_path=".env"
  cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
fi

# Handle the case where there is no application
if [ ${#APPS[@]} -eq 0 ]; then
  for ENV in "${ENVS[@]}"; do
    vault_path="$PROJECT_SLUG/$ENV"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    env_path=".env.$ENV"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
fi

# Handle the case where there is no environment
if [ ${#ENVS[@]} -eq 0 ]; then
  for APP in "${APPS[@]}"; do
    vault_path="$PROJECT_SLUG/$APP"
    env_path="apps/$APP/.env"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
fi

# Handle the case where there is at least one application and one environment
for APP in "${APPS[@]}"; do
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  echo -e "${BOLD_TEXT}Pushing secrets for $APP${RESET_TEXT}"
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  for ENV in "${ENVS[@]}"; do
    echo
    vault_path="$PROJECT_SLUG/$ENV/$APP"
    env_path="apps/$APP/.env.$ENV"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
  echo
done
