# Service Architecture

Deployment consists of two services


## Services
- kms-svc
    - Responsible for providing apis to client for storing and getting crypt assets
- vault-svc
    - KMS backend for storing crypto asets

## Orchestration Tool
For orchestration, ECS was the choice made as compared to Kubernetes:
- Ease of setting up clusters and off loading management of clusters to AWS
- My fairly limited experience with Kubernetes

### Tradeoffs:
- This architecture has less control over the underlying system. 
- Vendor lockin


## Persistent Storage
For HA, the choice was between Consul and Dynamodb
Again decided to choose DynamoDb because:
- Removed complexity of manageing additional secret backend
- Better integration with ECS containers providind RBAC access.

### Tradeoffs:
- Although dynamodb supports HA, but it is community module for vault
- secrets store (in encrypted form) in cloud

## Latency improvment
- For further latency improvment, ElasticCache can be used. 
Note: It is not implement in current version