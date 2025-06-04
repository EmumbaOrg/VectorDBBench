#!/bin/bash
set -e

# Initialize variables
deploy_aws=false
deploy_azure=false
deploy_gcp=false

# Function to show usage
usage() {
    echo "Usage: $0 [-a] [-z] [-g] [-az] [-ag] [-zg] [-azg]"
    echo "  -a  Deploy AWS resources"
    echo "  -z  Deploy Azure resources"
    echo "  -g  Deploy GCP resources"
    exit 1
}

# Parse flags
while getopts ":azg" opt; do
  case ${opt} in
    a )
      deploy_aws=true
      ;;
    z )
      deploy_azure=true
      ;;
    g )
      deploy_gcp=true
      ;;
    \? )
      usage
      ;;
  esac
done

# Ensure at least one flag is provided
if [ "$deploy_aws" = false ] && [ "$deploy_azure" = false ] && [ "$deploy_gcp" = false ]; then
    echo "Error: At least one cloud provider flag must be specified."
    usage
fi

# Debug logs for terraform
logFilePath=$PWD
export TF_LOG="INFO"                          #acceptable values in order of decreasing verbosity: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG_PATH="$logFilePath/terraform-create.log"

# Run Terraform with the specified variables
echo "Checking terraform plugins"
terraform init -reconfigure 

echo "Validating configuration"
if terraform validate | grep -q 'Success!'; then
  echo "Configuration is valid"
else 
  echo "Please check terraform configuration"
fi

echo "Creating terraform plan"
terraform plan -out main.tfplan -var="deploy_aws=${deploy_aws}" -var="deploy_azure=${deploy_azure}" -var="deploy_gcp=${deploy_gcp}"

# User confirmation
echo "Do you want to create resources using Terraform? (y/n)"
read -r user_input

# Convert input to lowercase (for case insensitivity)
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

case "$user_input" in
  y|yes )
      echo "Applying terraform plan"
      if terraform apply main.tfplan | grep -q 'complete!'; then
        echo "Resources have been created successfully."
      else 
        echo "Resource creation failed. Please check logs for more details."
      fi
      ;;
  n|no )
      echo "Terraform deployment aborted."
      exit 1
      ;;
  * )
      echo "Invalid input. Please enter 'y' for Yes or 'n' for No."
      exit 1
      ;;
esac

unset TF_LOG
unset TF_LOG_PATH