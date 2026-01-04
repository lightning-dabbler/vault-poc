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
