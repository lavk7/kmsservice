# Deployment

## Prerequisite
- Deps tested with:
    - terraform : v0.11.12
    - aws       : 1.16.93
    - linux     : ubuntu 18.04-lts
    - vault     : v1.0.3
- Create ECR repo for :
    - vault
    - kmsservice
- Replace ECR repository arn of each service to the respective `build.sh` file present in `/build/${service}/build.sh`

## Build
- Run build on each service
```
bash build/kmsservice/build.sh
bash build/vault/build.sh
```

## Configuration
- Replace the image of each service in task definition json of each service in dir `deploy/ecs/task-definitions/[kms/vault]`

## Run Terraform
```
cd deploy/prod/ecs
terraform init
terraform apply -auto-approve
```

## Post Configuration
- Do first time initialization of vault by accessing the container public ip ( Not automated  currently) 
- Note down the Root token and master password
- Enter value of `CRYPTOGEN_VAULT_SHARD` and `CRYPTOGEN_VAULT_TOKEN` in `deploy/prod/ecs/kms/task.json` with respectively master password and Root token
- Run terraform plan again
    ```
    cd deploy/prod/ecs
    terraform apply -auto-approve
    ```

## Check
- '$ curl -i ${dns_name}/health`