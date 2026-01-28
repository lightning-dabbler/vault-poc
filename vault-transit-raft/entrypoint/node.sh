#!/usr/bin/env bash
set -e

# running on vault secrets engine server

VAULT_SERVER_NUM="${VAULT_SERVER_NUM:-1}"
VAULT_SERVER="vault-raft-server-${VAULT_SERVER_NUM}"
VAULT_UNSEAL_TOKEN_PATH="${VAULT_UNSEAL_TOKEN_PATH:-/vault/external/transit-engine/root-token.txt}"
RECOVERY_SHARES="${RECOVERY_SHARES:-5}"
RECOVERY_THRESHOLD="${RECOVERY_THRESHOLD:-3}"
RECOVERY_FILE="/vault/vault/file/recovery-shares.json"

VAULT_TRANSIT_TOKEN=`cat $VAULT_UNSEAL_TOKEN_PATH`

export VAULT_TOKEN="$VAULT_TRANSIT_TOKEN"

# create path for vault raft storage
mkdir -p /vault/vault/data

export VAULT_ADDR="http://127.0.0.1:8200"

echo "Starting ${VAULT_SERVER}..."
# Start Vault in background
vault server -config=/vault/config/vault.hcl &
VAULT_PID=$!

sleep 2

vault_status=-1
OUTPUT="$(vault status)" || vault_status=$?

if [[ $vault_status -eq 1 ]]; then
    echo "Vault server is in an errored state"
    exit 1
fi

# Create recovery file if it doesn't exist and vault-1 is the initial leader node
if [ ! -f "$RECOVERY_FILE" ] && [ "$VAULT_SERVER_NUM" = "1" ]; then
        echo "Initializing ${VAULT_SERVER}"
        mkdir -p "$(dirname "$RECOVERY_FILE")"
        echo "recovery shares: $RECOVERY_SHARES, recovery threshold: $RECOVERY_THRESHOLD"
        # https://developer.hashicorp.com/vault/docs/commands/operator/init
        vault operator init -format=json -recovery-shares=$RECOVERY_SHARES -recovery-threshold=$RECOVERY_THRESHOLD > "$RECOVERY_FILE"
        # only current user should access file (vault user)
        chmod 600 "$RECOVERY_FILE"
fi

unset VAULT_TOKEN
# Keep alive
wait $VAULT_PID
