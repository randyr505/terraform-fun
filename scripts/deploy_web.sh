#!/bin/sh
# Author: Randy L Rasmussen
# Date  : 2018/07/22
date

cd ~/MyProjects/onica

# Remove previous creds and terraform build
#rm -fr files/terraform_credentials Terraform/.terraform
rm -fr files/terraform_credentials

# Create credentials file form csv downloaded from AWS
scripts/generate_creds.sh onicaaccessKeys.csv || exit $?

# Install latest terrform if not found in path
which terraform 2>&1 > /dev/null || scripts/install_terraform.sh || exit $?

# Build application
cd Terraform

# Set vars required for terraform init
s3=s3/variables.tf
backend=backend-generated.conf
app_env=$(grep 'variable "application_environment"' -A 2 variables.tf | tail -1 | awk -F\" '{print$2}')
bucket=$(grep 'variable "bucket_name"' -A 2 variables.tf | tail -1 | awk -F\" '{print$2}')
region=$(grep 'variable "aws_region"' -A 2 variables.tf | tail -1 | awk -F\" '{print$2}')
pkgs=$(grep 'variable "web_packages"' -A 2 variables.tf | tail -1 | awk -F\" '{print$2}')

# Create dynamic variables.tf file for initial bucket creation
echo 'variable "bucket_name" { default = "'$bucket'" }
variable "aws_region" { default = "'$region'" }
variable "application_environment" { default = "'$app_env'" }' > $s3

cd s3
terraform init || exit 1
terraform plan -input=false || exit 1
terraform apply -auto-approve -input=false || exit 1
cd ..

# Create dynamic backend config
echo 'bucket = "'$bucket'"
key    = "'$bucket'.tfstate"
region = "'$region'"' > $backend

# Initialize terraform
terraform init -backend-config $backend || exit 1
terraform plan -input=false || exit 1
terraform apply -auto-approve -input=false || exit 1

date
../scripts/notify_slack.sh Web Build Complete
