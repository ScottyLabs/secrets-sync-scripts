# DEFINE PROJECT SPECIFIC CONFIGURATIONS HERE
export PROJECT_SLUG="governance"
export APPLICATIONS_OPTIONS=()
export ENVIRONMENTS_OPTIONS=()

# DON'T EDIT BELOW THIS LINE
export VAULT_ADDR=https://secrets.scottylabs.org
export VAULT_MOUNT=ScottyLabs

APPLICATIONS_OPTIONS_JOINED=$(printf ' | %s' "${APPLICATIONS_OPTIONS[@]}")
ENVIRONMENTS_OPTIONS_JOINED=$(printf ' | %s' "${ENVIRONMENTS_OPTIONS[@]}")
export APPLICATIONS_OPTIONS_JOINED=${APPLICATIONS_OPTIONS_JOINED:3} # remove leading ' | '
export ENVIRONMENTS_OPTIONS_JOINED=${ENVIRONMENTS_OPTIONS_JOINED:3} # remove leading ' | '

export RED_TEXT="\033[31m"
export BLUE_TEXT="\033[34m"
export BOLD_TEXT="\033[1m"
export RESET_TEXT="\033[0m"

export SETUP_NOT_COMPLETED_MESSAGE="${RED_TEXT}Please read scripts/secrets/README.md \
and complete the setup before using the secrets sync scripts!${RESET_TEXT}"
