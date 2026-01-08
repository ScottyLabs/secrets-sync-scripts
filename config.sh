#!/usr/bin/env bash
export VAULT_ADDR=https://secrets.scottylabs.org
export VAULT_MOUNT=ScottyLabs

export RED_TEXT="\033[31m"
export BLUE_TEXT="\033[34m"
export BOLD_TEXT="\033[1m"
export RESET_TEXT="\033[0m"

# Convert space-separated strings to arrays
read -r -a ALLOWED_APPS_ARR <<<"$ALLOWED_APPS"
read -r -a ALLOWED_ENVS_ARR <<<"$ALLOWED_ENVS"

# Shared Usage Message Template
usage_common() {
  local script_name="$1"
  local action="$2" # either "pull" or "push"

  # Join the allowed apps and envs into a single string with ' | ' as a separator.
  local allowed_apps_joined allowed_envs_joined
  allowed_apps_joined=$(printf ' | %s' "${ALLOWED_APPS_ARR[@]}")
  allowed_envs_joined=$(printf ' | %s' "${ALLOWED_ENVS_ARR[@]}")
  allowed_apps_joined=${allowed_apps_joined:3} # remove leading ' | '
  allowed_envs_joined=${allowed_envs_joined:3} # remove leading ' | '

  echo
  echo -e "${BOLD_TEXT}Usage:${RESET_TEXT}"
  echo -e "  $script_name APP ENV"
  echo
  echo -e "${BOLD_TEXT}Description:${RESET_TEXT}"
  echo -e "  ${action} secrets between the local environment and Vault."
  echo
  echo -e "${BOLD_TEXT}Requirements:${RESET_TEXT}"
  echo -e "  - PROJECT_SLUG must be defined."
  echo -e "  - ALLOWED_APPS must be defined (space-separated string of valid applications)."
  echo -e "  - ALLOWED_ENVS must be defined (space-separated string of valid environments)."
  echo
  echo -e "${BOLD_TEXT}Arguments:${RESET_TEXT}"
  echo -e "  APP   The application to ${action}, one of: $allowed_apps_joined | all"
  echo -e "  ENV   The environment to ${action}, one of: $allowed_envs_joined | all"
  echo
  echo -e "${BOLD_TEXT}Options:${RESET_TEXT}"
  echo -e "  -h, --help    Show this help message and exit"
  echo
  echo -e "${BOLD_TEXT}Example Usage:${RESET_TEXT}"
  echo -e "  PROJECT_SLUG=my-project ALLOWED_APPS='web server' ALLOWED_ENVS='dev staging prod' $script_name all prod"
}

# Helper function to validate the app/env input
validate_input() {
  local input="$1"  # the specific value provided by the user (e.g. "web")
  local action="$2" # either "pull" or "push"
  local type="$3"   # either "application" or "environment"
  shift 3
  local allowed_list=("$@") # list of allowed options
  local result=()           # the validated result

  # If the user passes "all", set the target array to the allowed list
  if [ "$input" == "all" ]; then
    result=("${allowed_list[@]}")

  # Otherwise, validate the input against the allowed list
  else
    local valid=false
    for opt in "${allowed_list[@]}"; do
      if [ "$input" == "$opt" ]; then
        result=("$input")
        valid=true
        break
      fi
    done

    # Show an error message and exit if the input is not valid
    if [ "$valid" == false ]; then
      echo -e "${RED_TEXT}Error: Invalid $type '$input'.${RESET_TEXT}" >&2
      usage_common "$0" "$action"
      exit 1
    fi
  fi

  # Print the validated result as a newline-separated list to be captured by the caller
  if [ "${#result[@]}" -gt 0 ]; then
    printf '%s\n' "${result[@]}"
  fi
}

# Shared Argument Parsing and Validation
parse_args() {
  local script_name="$1"
  local action="$2"
  shift 2
  unset APP ENV

  # Read the arguments
  while [[ "$#" -gt 0 ]]; do
    # Show help message and exit if the user passes the -h or --help flag
    case "$1" in -h | --help)
      usage_common "$script_name" "$action"
      exit 0
      ;;
    esac

    # The first argument is the application and the second argument is the environment
    # Show an error message and exit if the user passes in more than two arguments.
    if [[ -z "$APP" ]]; then
      APP="$1"
    elif [[ -z "$ENV" ]]; then
      ENV="$1"
    else
      echo -e "${RED_TEXT}Error: Too many arguments provided${RESET_TEXT}" >&2
      usage_common "$script_name" "$action"
      exit 1
    fi

    shift
  done

  # Show an error message and exit if the user does not provide an application or environment
  if [ -z "$APP" ]; then
    echo -e "${RED_TEXT}Error: Application is required${RESET_TEXT}" >&2
    usage_common "$script_name" "$action"
    exit 1
  fi

  if [ -z "$ENV" ]; then
    echo -e "${RED_TEXT}Error: Environment is required${RESET_TEXT}" >&2
    usage_common "$script_name" "$action"
    exit 1
  fi

  # Validate the input and store the results in the APPS and ENVS arrays
  APPS=()
  while IFS= read -r line; do
    APPS+=("$line")
  done < <(validate_input "$APP" "$action" "application" "${ALLOWED_APPS_ARR[@]}")

  ENVS=()
  while IFS= read -r line; do
    ENVS+=("$line")
  done < <(validate_input "$ENV" "$action" "environment" "${ALLOWED_ENVS_ARR[@]}")
}
