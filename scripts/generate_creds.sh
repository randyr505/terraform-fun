#!/bin/sh
# Author: Randy L Rasmussen
# Date  : 2018-07-22
DIR=~/MyProjects/terraform-fun

# Assign first argument as aws csv file
access_key_csv=$DIR/files/$1

# Used with bail function to print the usage of this script
USAGE="\nUSAGE: $0 access_key_file.csv

  This script adds an access key csv file from aws to a properly formatted
  credentials file to use for automation. It processes the last line of the file
"

# Print message, return error code passed in, and optionally print USAGE
bail() {
  # Author: Randy L Rasmussen
  # Date: 2015-11-16
  # Example use to show return code of command but exit with different code, i.e. 1
  # { rc=$?; bail "Mount command failed for an unknown reason, rc=$rc" 1; }
  msg=$1; code=$2; usage=$3
  # Set USAGE var to usage & description prior to line including this function"
  # use \n for new lines, -e will utilize backslash escapes
  [ "$usage" == "usage" ] && printf "$USAGE"
  echo ""; echo "*** $msg ***"; echo ""
  [ -n "$code" ] && exit $code
}

# Exit if EXACTLY one argument wasn't provided
[ $# -eq 1 ] || bail "\nProvide only ONE argument." 1 usage

# Setup credential varialbes
access_name=terraform
creds="$DIR/files/${access_name}_credentials"

# Validate creds file exists
[ -f "$creds" ] && bail "Credentials file $creds already exists" 1 usage

# Create credentials file to interact progmatically with AWS
create_creds() {
  tail -1 $access_key_csv | awk -F, -v a=$access_name \
    '{print "["a"]\naws_access_key_id = "$1"\naws_secret_access_key = "$2}' \
    > ${creds} && bail "Credentials file $creds successfully created" $?
}

# if csv credentials exist, create credentials file
[ -f $access_key_csv ] && create_creds
