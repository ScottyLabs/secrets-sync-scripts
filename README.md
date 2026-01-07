# Secrets Sync Scripts

This directory contains scripts that are used to manage the project's secrets
using [Vault](https://github.com/ScottyLabs/wiki/wiki/Credentials#hashicorp-vault).

## Usage

### `config.sh`

This script contains the configuration used by the other scripts.
The project slug is what you defined in
[Governance](https://github.com/ScottyLabs/governance/tree/main/teams).

The scripts will sync with secrets stored in the vault path
`ScottyLabs/$PROJECT_SLUG/$ENV/$APP`, for every application and environment.

When there is only one application, the scripts will sync with secrets stored
in the vault path `ScottyLabs/$PROJECT_SLUG/$ENV`, for every environment.

### setup.sh

Log into the Vault using the OIDC method. You have to run this script
before pulling or pushing secrets, or you will get permission denied errors.
Copy the link from the terminal and paste it in your browser if the link doesn't
automatically open.

```zsh
./scripts/secrets-setup.sh
```

### `pull.sh`

Pulls the secrets from the Vault and saves them to the corresponding `.env` file.
Run the following command to see the usage:

```zsh
./scripts/secrets-pull.sh -h
```

### `push.sh`

Pushes the secrets to the Vault from the corresponding `.env` file.
Run the following command to see the usage:

```zsh
./scripts/secrets-push.sh -h
```
