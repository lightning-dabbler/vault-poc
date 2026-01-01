#!/usr/bin/env bash
set -e

# running on vault secrets engine server

VAULT_SERVER_NUM="${VAULT_SERVER_NUM:-1}"
VAULT_SERVER="vault-raft-server-${VAULT_SERVER_NUM}"
VAULT_UNSEAL_TOKEN_PATH="${VAULT_UNSEAL_TOKEN_PATH:-/vault/external/transit-engine/wrapping-token.txt}"

WRAPPED_TOKEN=`cat $VAULT_UNSEAL_TOKEN_PATH`
VAULT_TOKEN=`vault unwrap -field=token $WRAPPED_TOKEN`
export VAULT_TOKEN="$VAULT_TOKEN"
# create path for vault raft storage
mkdir -p /vault/vault/data
# create path for vault server output
mkdir -p /vault/vault/output
# creaate path for vault server logs
mkdir -p /vault/vault/logs

echo

echo "Starting ${VAULT_SERVER}..."

# Start Vault in background
vault server -config=/vault/config/vault.hcl &
VAULT_PID=$!

sleep 2
