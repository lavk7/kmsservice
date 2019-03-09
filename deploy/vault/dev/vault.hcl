storage "dynamodb" {
  ha_enabled = "true"
  region     = "ap-southeast-1"
  table      = "vault_backend"
  access_key = "AKIAICBXRU7KTMJU5EMA"
  secret_key = "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"
}

listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 1
}

ui = true