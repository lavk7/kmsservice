storage "dynamodb" {
  ha_enabled = "true"
  region     = "ap-southeast-1"
  table      = "vault_backend"
}

listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 1
}

ui = true
disable_mlock = true