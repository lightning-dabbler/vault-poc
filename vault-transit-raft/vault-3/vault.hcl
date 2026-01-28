disable_mlock = true
cluster_addr = "http://vault-raft-server-3:8201"
api_addr = "http://vault-raft-server-3:8200"
ui = true

storage "raft" {
    path = "/vault/vault/data"
    node_id = "vault-3"

    retry_join {
        leader_api_addr = "http://vault-raft-server-1:8200"
    }
    retry_join {
        leader_api_addr = "http://vault-raft-server-2:8200"
    }
}

listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable = true
}

seal "transit" {
   address            = "http://vault-transit-secrets-engine:8200"
   disable_renewal    = "false"

   // Key configuration
   key_name = "autounseal"
   mount_path         = "transit/"
   tls_skip_verify = "true"
}
