# TODO list

- Use S3 backend with DynamoDB locking for remote state storage and concurrent access protection
- Split into separate Terraform stacks (common, vm-cluster, autonomous) with independent state files
- Create an Ops EC2 bastion instance for running Ansible playbooks and SQLcl commands
- Implement Ansible playbooks for VM Cluster and Autonomous database configuration
- Add OCI Provider alongside AWS for managing OCI-native resources (wallets, backups, Data Guard)
- Configure Data Guard between two VM Clusters for cross-region replication
