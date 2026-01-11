#!/usr/bin/env bash
set -e

# Load common variables and functions
source $(dirname "$0")/common.sh

# Parse arguments
parse_args "$@"

# Load the push function
source "$(dirname "$0")/../common/push-util.sh"

# Run the push
source "$(dirname "$0")/run.sh"
