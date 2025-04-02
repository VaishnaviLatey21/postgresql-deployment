#!/bin/bash

# Prompt user for database credentials
echo "Enter the database name:"
read DB_NAME
echo "Enter the database username:"
read DB_USER
echo "Enter the database password:"
read -s DB_PASS  # Silent input for password

DB_URL="jdbc:postgresql://my-release-postgresql.default:5432/$DB_NAME"

# Update values.yaml
echo "Updating values.yaml with new credentials..."
sed -i "s/\(postgresPassword: \).*/\1\"$DB_PASS\"/" values.yaml
sed -i "s/\(username: \).*/\1\"$DB_USER\"/" values.yaml
sed -i "s/\(database: \).*/\1\"$DB_NAME\"/" values.yaml

# Update pod.yaml
echo "Updating pod.yaml with new credentials..."
sed -i "s/\(name: DB_USER.*value: \).*/\1\"$DB_USER\"/" pod.yaml
sed -i "s/\(name: DB_PASS.*value: \).*/\1\"$DB_PASS\"/" pod.yaml
sed -i "s|\(name: DB_URL.*value: \).*|\1\"$DB_URL\"|" pod.yaml

echo "values.yaml and pod.yaml updated successfully."

# Deploy changes
echo "Applying Helm and Kubernetes changes..."
helm upgrade --install postgresql  bitnami/postgresql -f values.yaml
kubectl apply -f pod.yaml

