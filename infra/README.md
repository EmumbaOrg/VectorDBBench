# TERRAFORM MULTI CLOUD DEPLOYMENT STEPS
This guide is intended to define steps for the creation of vector benchmarking resources through terraform scripts. The deployment performs following steps:-
1. Create resources on cloud providers (AWS, Azure and GCP).
2. Monitor performance of underlying hardware with netdata monitoring tool.
3. Destroy resources provisioned on cloud providers.

## PRE-REQUISITE
Following tools are the required to be installed before using the architecture. This architecture can be used on cloud as well as local computer. See Architecture layout section.
### Local Machine
1. [Terraform](https://developer.hashicorp.com/terraform/install) latest version - for execution of terraform scripts
2. [git](https://git-scm.com/downloads) - clone benchmarking repository
3. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - for authentication with AWS, you must configure user credentials with appropriate / least privilege permissions for resource creation within a region
4. [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - for Azure resource deployment, configure the user with necessary resource group level permissions
5. [gcloud cli](https://cloud.google.com/sdk/docs/install) - for GCP deployment, user configured must have least privilege permissions to be able to create resources
### On Cloud
1. A virtual machine deployed on any cloud provider in public subnet with internet access.
2. An object storage for remote backend of terraform
3. [Terraform](https://developer.hashicorp.com/terraform/install) latest version - for execution of terraform scripts
4. [git](https://git-scm.com/downloads) - clone benchmarking repository
5. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - for authentication with AWS, you must configure user credentials with appropriate / least privilege permissions for resource creation within a region
6. [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - for Azure resource deployment, configure the user with necessary resource group level permissions
7. [gcloud cli](https://cloud.google.com/sdk/docs/install) - for GCP deployment, user configured must have least privilege permissions to be able to create resources.

**Note:** If the tools mentioned above are already deployed or benchmark is not required to be run on certain cloud provider, you can skip the cli tool for that provider.

## ARCHITECTURE LAYOUT
Following architecture has been used in the creation of resources. The resources highlighted in blue box is the machine which runs the terraform scripts. The architecture can be setup on local machine as well as a virtual machine provisioned on any cloud provider. To reduce the dependency to run the local machine for extended period, a virtual machine has already been deployed in a separate resource group as shown in the layout. The resources highlighted in the green box are the resources which will be provisioned as a result of execution of these scripts. An object storage is also required to initialize remote backend for terraform which terraform uses to identify an activity if multiple users are running the benchmark simulatanously. 
The workflow will create four types of resources on aforementioned cloud providers, namely:-
1. Virtual private network (VPC) / Virtual network (VNET) - for resource deployment in dedicated subnets
2. Benchmark virtual machine - to run Hammerdb and VectorDB benchmark
3. Managed PostgreSQL machine - to evaluate performance of managed PostgreSQL machine
4. Self hosted PostgreSQL machine - to determine the performance of self managed open source PostgreSQL
![MSFT Terraform deployment](https://github.com/user-attachments/assets/b2738417-3912-4781-b590-fbcf201c2e8f)

## DIRECTORY STRUCTURE
Directory structure of infrastructure directory is as follows. The root directory contains `scripts` folder, `providers.tf` and `terraform.tfvars` files alongwith other files. All the variables of every cloud provider can be configured from one file i.e. `terraform.tfvars`. Provider configuration for each cloud provider can also be configured from `providers.tf` file.  
The root directory contains three sub modules namely, `aws`, `azure` and `gcp`. Each submodule in the root directory is further composed of four submodules alongwith `main.tf`, `variables.tf` and `outputs.tf`. 

```bash
.
├── aws
│   ├── aws-bench-ec2
│   │   └── bench-setup.sh
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── aws-db-ec2
│   │   └── pgdb-setup.sh
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── aws-rds-postgres
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── aws-vpc
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── main.tf
│   ├── variables.tf
├── azure
│   ├── azure-benchvm-iac
│   │   └── bench-setup.sh
│   │   └── main.tf
│   │   └── providers.tf
│   │   └── variables.tf
│   ├── azure-flex-iac
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── azure-pgvm-iac
│   │   └── pgvm-setup.sh
│   │   └── main.tf
│   │   └── providers.tf
│   │   └── variables.tf
│   ├── azure-vnet
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── main.tf
│   ├── variables.tf
├── gcp
│   ├── gcp-bench-ce
│   │   └── bench-setup.sh
│   │   └── main.tf
│   │   └── variables.tf
│   ├── gcp-cloudsql
│   │   └── main.tf
│   │   └── variables.tf
│   ├── gcp-db-ce
│   │   └── dbce-setup.sh
│   │   └── main.tf
│   │   └── variables.tf
│   ├── gcp-cnet
│   │   └── main.tf
│   │   └── outputs.tf
│   │   └── variables.tf
│   ├── main.tf
│   ├── variables.tf
├── scripts
│   ├── create.sh
│   ├── destroy.sh
├── .gitignore
├── main.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
├── README.md
```

## RESOURCE CREATION WORKFLOW
1. Run `./scripts/create.sh` script with cloud provider flag. The script checks the flag and configures terraform for cloud provider
2. Terraform execution starts initialization and checks the remote backend for any user activity.
3. If no user activity is found, it proceeds to validate the configuration.
4. After validation of configuration, terraform creates a plan for resource creation and prompts user before applying the plan. This user prompt has been added to prevent misconfiguration.
5. After user confirmation, terraform creates resources.
6. To debug errors or check the progress of resource creation, check `terraform-create.log` file for details
7. To monitor the performance of resources through netdata monitoring tool, use this link `http://<public-ip>:19999` where public-ip is the internet reachable IP of resource.
![Terraform WF](https://github.com/user-attachments/assets/a3292745-5e18-4d1b-ac4b-a5c55d6dd512)


### EXECUTION STEPS
1. Install the tools from the pre-requisites section
2. Configure cli of each cloud provider
  - For aws, `aws configure`
  - For azure, `az login`
  - For gcloud, `gcloud auth application-default login`
3. Check `terraform.tfvars` file to configure resources across cloud providers
4. In the scripts directory, give appropriate permissions to the `create.sh` and `destroy.sh`
5. Run `./scripts/create.sh` script with flags for cloud provider you want to provision resources. The script accepts `-a` for aws, `-z` for azure, `-g` for gcp, a combination of these flags or all the flags (for instance, `-ag`, `-gz`, `-azg` etc). Run `./scripts/create.sh` script without any flag to get usage `help`. 

## RESOURCE DESTRUCTION WORKFLOW
[!CAUTION] Caution is advised as the desroy script deletes all the resources deployed on all cloud providers.
### EXECUTION STEPS
1. Run `./scripts/destroy.sh` script.
2. The script prompts user to confirm deletion.
3. After confirmation, terraform destroys all the resources it has provisioned previously.
4. To debug errors or check the progress of resource creation, check `terraform-destroy.log` file for details
