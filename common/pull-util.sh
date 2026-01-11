#!/usr/bin/env bash
pull() {
  local env_path="$1"
  local vault_path="$2"
  echo -e "${BLUE_TEXT}Pulling from \"$vault_path\" to \"$env_path\"${RESET_TEXT}"
  vault kv get -format=json "$vault_path" |
    jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' >$env_path
}
