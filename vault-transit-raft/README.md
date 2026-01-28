# Vault cluster with auto unseal
Vault cluster leveraging Raft for distributed storage and Transit engine for automated unsealing.

## Architecture

### Components
- **Vault Secrets Cluster**: 3 nodes with Raft storage
- **Vault Transit Secrets Engine**: 1 node for auto-unsealing
- **HAProxy**: Load balancer
    - Vault address: http://localhost:8200
    - HAProxy stats page: http://localhost:8404/stats

### Features
- Automatic unsealing via Transit engine
- Raft consensus for HA
- Active/standby failover

### Expected Results
**Root token location:**
```
./vault-transit-raft/vault-1/data/vault/file/recovery-shares.json
```
**Cluster status:**
```console
$ export VAULT_TOKEN=<Root token in file above>
$ export VAULT_ADDR=http://localhost:8200
$ vault operator raft list-peers
Node       Address                     State       Voter
----       -------                     -----       -----
vault-1    vault-raft-server-1:8201    leader      true
vault-3    vault-raft-server-3:8201    follower    true
vault-2    vault-raft-server-2:8201    follower    true
```
**All nodes unsealed:**
```console
$ vault status
Key                      Value
---                      -----
Seal Type                transit
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.20.4
Build Date               2025-09-23T13:22:38Z
Storage Type             raft
Cluster Name             vault-cluster-47442622
Cluster ID               072f37dd-1260-17d5-a221-4dc93d394770
Removed From Cluster     false
HA Enabled               true
HA Cluster               https://vault-raft-server-1:8201
HA Mode                  active
Active Since             2026-01-28T00:25:58.723260679Z
Raft Committed Index     46
Raft Applied Index       46
```

## Architechure diagram

### Diagram
![Architectural diagram](../diagrams/assets/vault_transit_secrets_engine_architecture.png)

### Generating diagram
In docker environment from root:
```console
$ uv run diagrams/scripts/vault-transit-raft.py
```

## Reference
- https://developer.hashicorp.com/vault/docs/secrets/transit
- https://developer.hashicorp.com/vault/tutorials/raft/raft-storage
- https://developer.hashicorp.com/vault/docs/internals/integrated-storage
- https://github.com/hashicorp-education/learn-vault-raft/blob/main/raft-ha-storage/new_cluster/cluster.sh
- https://github.com/hashicorp-education/learn-vault-raft/blob/main/raft-storage/local/cluster.sh
- https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-transit
- https://developer.hashicorp.com/vault/tutorials/archive/production-hardening
- https://docs.haproxy.org/3.2/configuration.html
