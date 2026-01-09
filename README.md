# Secrets Sync Scripts

This directory contains scripts that are used to manage the project's secrets
using [Vault](https://github.com/ScottyLabs/wiki/wiki/Credentials#hashicorp-vault).

## Usage

### `common.sh`

This script contains the common variables and functions used by the other scripts,
including the argument parsing and validation logic.

### `setup.sh`

Log into the Vault using the OIDC method. You have to run this script
before pulling or pushing secrets, or you will get permission denied errors.
Copy the link from the terminal and paste it in your browser if the link doesn't
automatically open.

```zsh
./setup.sh
```

### `pull.sh`

Pulls the secrets from the Vault and saves them to the corresponding `.env` file.
Run the following command to see the usage:

```zsh
./pull.sh -h
```

### `push.sh`

Pushes the secrets to the Vault from the corresponding `.env` file.
Run the following command to see the usage:

```zsh
./push.sh -h
```

## Configuration Variables

The PROJECT (required) is the team slug you defined in
[Governance](https://github.com/ScottyLabs/governance/tree/main/teams).

The APPS (optional) is a space-separated string of valid applications. Each
application is a directory in the `apps` directory.

The ENVS (optional) is a space-separated string of valid environments.
Each environment will create a `.env.$ENV` file in the root directory.

## Syncing Behavior

When there is at least one application and one environment, the scripts
sync local secrets from `apps/$APP/.env.$ENV` to the vault path
`ScottyLabs/$PROJECT/$ENV/$APP`, for every application and environment.

When there is no application, the scripts sync local secrets from `.env.$ENV`
to the vault path `ScottyLabs/$PROJECT/$ENV`, for every environment.

When there is no environment, the scripts sync local secrets from `apps/$APP/.env`
to the in the vault path `ScottyLabs/$PROJECT/$APP`, for every application.

When there is no application and no environment, the scripts sync local secrets
from `.env` to the vault path `ScottyLabs/$PROJECT`.
This script contains the configuration and helper functions used by the other scripts,
including argument parsing and validation.

**Exception**: when the `ENV` is `applicants`, the local secrets file name will be
`.env` instead of `.env.applicant`.
