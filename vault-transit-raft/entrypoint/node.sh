#!/usr/bin/env bash
set -e

# running on vault secrets engine server

VAULT_SERVER_NUM="${VAULT_SERVER_NUM:-1}"
VAULT_SERVER="vault-raft-server-${VAULT_SERVER_NUM}"
VAULT_UNSEAL_TOKEN_PATH="${VAULT_UNSEAL_TOKEN_PATH:-/vault/external/transit-engine/root-token.txt}"

ROOT_TOKEN=`cat $VAULT_UNSEAL_TOKEN_PATH`

export VAULT_TOKEN="$ROOT_TOKEN"
# create path for vault raft storage, vault server output, and vault server logs
mkdir -p /vault/vault/data /vault/vault/output /vault/vault/logs


export VAULT_ADDR="http://127.0.0.1:8200"

echo "Starting ${VAULT_SERVER}..."
# Start Vault in background
vault server -config=/vault/config/vault.hcl &
VAULT_PID=$!

sleep 2

# Keep alive
wait $VAULT_PID
