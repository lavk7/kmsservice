storage "dynamodb" {
  ha_enabled = "true"
  region     = "ap-southeast-1"
  table      = "vault_backend"
  access_key = ""
  secret_key = ""
}

listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 1
}

ui = true