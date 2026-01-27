# Vault POC

Proof-of-concept implementations for HashiCorp Vault

## Development

### Prerequisites
- **Docker & Docker Compose**
- **Make**
- Pre-commit (optional)

## Projects
### [Vault Transit + Raft Cluster](vault-transit-raft/README.md)
3-node HA Vault cluster with Raft storage and Transit auto-unseal.

#### Spin up vault-transit-raft containers
```console
$ make up
```

http://localhost:8200 exposes the vault cluster

#### Spin down vault-transit-raft containers
```console
$ make down
```

## Diagrams container
Shell into diagrams python container:
```console
$ make enter-diagrams
```

Remove container:
```console
$ make down-diagrams
```

## Make recipes
```
$ make
```
