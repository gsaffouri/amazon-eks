#!/bin/bash -e

aws secretsmanager get-secret-value --secret-id css-amazon-eks-key-pair | jq -r .SecretString > ~/.ssh/eks-managed-node-key-pair.sh

chmod 600 ~/.ssh/eks-managed-node-key-pair.sh
