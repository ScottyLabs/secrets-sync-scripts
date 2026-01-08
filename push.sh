#!/usr/bin/env bash
set -e

# Load the configuration
source scripts/secrets/config.sh

# Check if the setup is completed
if [ -z "$PROJECT_SLUG" ]; then
  echo -e "${SETUP_NOT_COMPLETED_MESSAGE}" >&2
  exit 1
fi

# Print usage
usage() {
  echo
  echo -e "\tUsage: $0 APPLICATION ENVIRONMENT\n"
  echo -e "\t\tAPPLICATION: The application to push to, one of $APPLICATIONS_OPTIONS_JOINED | all\n"
  echo -e "\t\tENVIRONMENT: The environment to push to, one of $ENVIRONMENTS_OPTIONS_JOINED | all\n"
  echo -e "\tOptions:"
  echo -e "\t\t-h, --help    Show this help message and exit\n"
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  *)
    if [[ -z "$APPLICATION" ]]; then
      APPLICATION="$1"
    elif [[ -z "$ENVIRONMENT" ]]; then
      ENVIRONMENT="$1"
    else
      echo "Error: Too many arguments provided: '$1'" >&2
      usage
      exit 1
    fi
    ;;
  esac
  shift
done

# Sanitize the Application argument
if [ "$APPLICATION" == "all" ]; then
  APPLICATIONS=("${APPLICATIONS_OPTIONS[@]}")
else
  valid=false
  for opt in "${APPLICATIONS_OPTIONS[@]}"; do
    if [ "$APPLICATION" == "$opt" ]; then
      APPLICATIONS=("$APPLICATION")
      valid=true
      break
    fi
  done

  if [ "$valid" == false ]; then
    echo "Error: Invalid application: '$APPLICATION'" >&2
    usage
    exit 1
  fi
fi

# Sanitize the Environment argument
if [ "$ENVIRONMENT" == "all" ]; then
  ENVIRONMENT=("${ENVIRONMENTS_OPTIONS[@]}")
else
  valid=false
  for opt in "${ENVIRONMENTS_OPTIONS[@]}"; do
    if [ "$ENVIRONMENT" == "$opt" ]; then
      ENVIRONMENT=("$ENVIRONMENT")
      valid=true
      break
    fi
  done

  if [ "$valid" == false ]; then
    echo "Error: Invalid environment: '$ENVIRONMENT'" >&2
    usage
    exit 1
  fi
fi

# Handle the case where there is no application and no environment
if [ ${#APPLICATIONS[@]} -eq 0 ] && [ ${#ENVIRONMENT[@]} -eq 0 ]; then
  vault_path="$VAULT_MOUNT/$PROJECT_SLUG"
  echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
  env_path=".env"
  vault kv put -mount="$VAULT_MOUNT" "$vault_path" <$env_path
fi

# Handle the case where there is no application
if [ ${#APPLICATIONS[@]} -eq 0 ]; then
  for ENV in "${ENVIRONMENT[@]}"; do
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$ENV"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    env_path=".env.$ENV"
    vault kv put -mount="$VAULT_MOUNT" "$vault_path" <$env_path
  done
fi

# Handle the case where there is no environment
if [ ${#ENVIRONMENT[@]} -eq 0 ]; then
  for APP in "${APPLICATIONS[@]}"; do
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$APP"
    env_path="apps/$APP/.env"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    vault kv put -mount="$VAULT_MOUNT" "$vault_path" <$env_path
  done
fi

# Handle the case where there is no environment
if [ ${#ENVIRONMENT[@]} -eq 0 ]; then
  for APP in "${APPLICATIONS[@]}"; do
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$APP"
    env_path="apps/$APP/.env"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    vault kv put -mount="$VAULT_MOUNT" "$vault_path" <$env_path
  done
fi

# Handle the case where there is at least one application and one environment
for APP in "${APPLICATIONS[@]}"; do
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  echo -e "${BOLD_TEXT}Pushing secrets for $APP${RESET_TEXT}"
  echo -e "${BOLD_TEXT}==================================================${RESET_TEXT}"
  for ENV in "${ENVIRONMENT[@]}"; do
    echo
    vault_path="$VAULT_MOUNT/$PROJECT_SLUG/$ENV/$APP"
    env_path="apps/$APP/.env.$ENV"
    echo -e "${BLUE_TEXT}Pushing to vault: $vault_path${RESET_TEXT}"
    cat $env_path | xargs -r vault kv put -mount="$VAULT_MOUNT" "$vault_path"
  done
  echo
done
