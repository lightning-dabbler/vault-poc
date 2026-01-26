#!/usr/bin/env bash
set -e

# running on vault transit secrets engine

KEYS_FILE="/vault/vault/file/init-keys.json"
KEY_SHARES="${KEY_SHARES:-5}"
KEY_THRESHOLD="${KEY_THRESHOLD:-3}"
AUDIT_LOGGING_FILE_PATH="/vault/vault/logs/audit.log"

# create path for vault raft storage
mkdir -p /vault/vault/data

echo "Starting vault transit secret engine..."
# Start Vault in background
vault server -config=/vault/config/vault.hcl &
VAULT_PID=$!

sleep 2

# Check that vault server is not in an errored state. Sealed state (exit code 2) is fine
# https://unix.stackexchange.com/questions/786103/in-bash-how-to-capture-stdout-and-the-exit-code-of-a-command-when-the-e-flag-i
vault_status=-1
OUTPUT="$(vault status)" || vault_status=$?

if [[ $vault_status -eq 1 ]]; then
    echo "Vault server is in an errored state"
    exit 1
fi

# Create keys file if it doesn't exist
if [ ! -f "$KEYS_FILE" ]; then
    echo "Initializing Vault transit secrets engine"
    mkdir -p "$(dirname "$KEYS_FILE")"
    echo "key shares: $KEY_SHARES, key threshold: $KEY_THRESHOLD"
    # https://developer.hashicorp.com/vault/docs/commands/operator/init
    vault operator init -format=json -key-shares=$KEY_SHARES -key-threshold=$KEY_THRESHOLD > "$KEYS_FILE"
    # only current user should access file (vault user)
    chmod 600 "$KEYS_FILE"
fi

# read key file and unseal vault transit secrets engine
UNSEAL_KEYS=$(jq -r '.unseal_keys_b64[]' "$KEYS_FILE")
for key in $UNSEAL_KEYS; do
    vault operator unseal "$key"
done
# check that vault transit secrets engine is unsealed
# https://developer.hashicorp.com/vault/docs/commands/status
# run vault status, any non-zero is an issue at this point
vault status

# export root token from file as VAULT_TOKEN
# Enable transit
ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
export VAULT_TOKEN="$ROOT_TOKEN"

# enable audit logging if not enabled
# https://developer.hashicorp.com/vault/docs/audit
audit_logging_file_enabled(){
    vault audit list -format=json | jq -e '.["file/"]' >/dev/null 2>&1
}

if ! audit_logging_file_enabled; then
    echo "Enabling file audit logging. Destination: $AUDIT_LOGGING_FILE_PATH"
    mkdir -p "$(dirname "$AUDIT_LOGGING_FILE_PATH")"
    vault audit enable file file_path=$AUDIT_LOGGING_FILE_PATH
fi

# enable transit secrets engine if not enabled
# https://developer.hashicorp.com/vault/docs/commands/secrets
transit_enabled(){
    vault secrets list -format=json | jq -e '.["transit/"]' >/dev/null 2>&1
}

if ! transit_enabled; then
    echo "Enabling transit"
    vault secrets enable transit
fi

# write autounseal keys
# Function to check if transit key exists in vault
key_exists() {
    vault list -format=json transit/keys 2>/dev/null | jq -r '.[]' 2>/dev/null | grep -q "^autounseal$"
}

# Create transit key if it doesn't exist
if ! key_exists; then
    echo "Creating transit key: autounseal"
    vault write -f transit/keys/autounseal
else
    echo "Transit key 'autounseal' already exists"
fi

# write autounseal policy (safe to rerun)
vault policy write autounseal -<<EOF
path "transit/encrypt/autounseal" {
   capabilities = [ "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "update" ]
}
EOF

# Create token for vault servers to use
vault token create -policy="autounseal" \
   -period=24h \
   -field=token > /vault/output/root-token.txt

# Keep alive
wait $VAULT_PID
