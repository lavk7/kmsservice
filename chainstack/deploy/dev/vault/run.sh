#!/bin/bash

docker rm -f vault-1 vault-2 vault-3
docker network rm net_vault
docker network create --subnet 192.168.150.0/28 net_vault


docker run  -d --cap-add=IPC_LOCK --name=vault-1 \
            -e VAULT_API_ADDR=http://127.0.0.1:8200 \
            -e VAULT_ADDR=http://127.0.0.1:8200 \
            vault

docker network connect --ip 192.168.150.2 net_vault vault-1

docker run  -d --cap-add=IPC_LOCK  --net=net_vault --name=vault-2 \
            -e VAULT_API_ADDR=http://192.168.150.2:8200 \
            -e VAULT_ADDR=http://127.0.0.1:8200 \
            vault

docker run  -d --cap-add=IPC_LOCK --net=net_vault --name=vault-3 \
            -e VAULT_API_ADDR=http://192.168.150.2:8200 \
            -e VAULT_ADDR=http://127.0.0.1:8200 \
            vault
