#!/bin/sh
# Author: Randy L Rasmussen
# Date  : 2018/07/22

# Architecture to filter against downloadable binaries
arch="amd64"

# Location to place terraform binary
mybin=~/bin

# Location to download binary
tmp=/tmp

# Determine os name to filter against downloadable binaries
os_name=$(uname -s | tr [A-Z] [a-z])

# Where to search for downloadable binaries
tf_url="https://releases.hashicorp.com/terraform/"

# Set to latest downloadable terraform version
tf_version=$(curl -s $tf_url | grep href | head -2 | tail -1 | awk -F\" '{print$2}' | awk -F\/ '{print$3}')

# Create url and zip for curl download
url=${tf_url}${tf_version}
zip=terraform_${tf_version}_${os_name}_${arch}.zip

# Download latest terraform binary
curl -s $url/$zip -o $tmp/$zip

# Change to directory where binary was downloaded
cd $tmp

# Extract binary and place in mybin location
unzip -B $zip -d $mybin && echo "Terraform installed successfully"
