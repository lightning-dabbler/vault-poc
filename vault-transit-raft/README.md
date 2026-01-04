# Vault transit with raft storage

## Resources
### vault transit secret engine
- 1 node
- Stores no data
- Storage layer is file system
- Acts as a cryptography engine for the vault secrets cluster
- Used to auto unseal vault nodes

### vault secrets cluster
- 3 nodes
- Using raft to replicate data across nodes (from leader to standby nodes) and persisting data on volume of each node
- High availability

### haproxy
- Load balancer for vault cluster

## Design diagram

![Architectural diagram](../diagrams/assets/vault_transit_secrets_engine_architecture.png)

### Generating diagram
In docker environment:
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
