# https://developer.hashicorp.com/vault/docs/configuration/seal/transit-best-practices
storage "file" {
    path = "/vault/vault/data"
}

listener "tcp" {
   address = "0.0.0.0:8200"
   tls_disable = true
}

ui = true
disable_mlock = true
api_addr = "0.0.0.0:8200"
