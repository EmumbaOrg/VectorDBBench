#!/bin/bash
set -e

# Initialize variables
deploy_aws=true
deploy_azure=true
deploy_gcp=true

# Debug logs for terraform
logFilePath=$PWD
export TF_LOG="INFO"                            #acceptable values in order of decreasing verbosity: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG_PATH="$logFilePath/terraform-destroy.log"

# User confirmation
echo "WARNING! Do you want to destroy all resources using Terraform? (y/n)"
read -r user_input

# Convert input to lowercase (for case insensitivity)
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

case "$user_input" in
  y|yes )
      echo "Destroying resources..."
      echo "Please check terraform-destroy.log file for detailed logs."  
      if terraform destroy -var="deploy_aws=${deploy_aws}" -var="deploy_azure=${deploy_azure}" -var="deploy_gcp=${deploy_gcp}" -auto-approve | grep -q 'complete!'; then
        echo "Resources have been destroyed successfully"
      else 
        echo "Resource destoy failed."
        echo "Please see terraform-destroy.log file for details."
      fi
      ;;
  n|no )
      echo "Terraform resource destruction aborted."
      exit 1
      ;;
  * )
      echo "Invalid input. Please enter 'y' for Yes or 'n' for No."
      exit 1
      ;;
esac

unset TF_LOG
unset TF_LOG_PATH