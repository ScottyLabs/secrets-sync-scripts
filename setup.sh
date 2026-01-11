#!/usr/bin/env bash
set -e
source "$(dirname "$0")/common/constants.sh" # load VAULT_ADDR variable
vault login -method=oidc
