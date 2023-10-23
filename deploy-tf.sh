#!/bin/bash -e

# Run this script to deploy changes to main, which executes GitHub Actions
# To make/test changes: Edit the files in the resources directory, and re-run this script

while getopts 'm:p' OPTION; do
  case "$OPTION" in
    m)
      argM="$OPTARG"
      ;;
    p)
      argP=$(git add . && git commit \-m '$argM' && git push)
      ;;
    ?)
      echo "Usage: $(basename $0) [-m argument] [-d]"
      exit 1
      ;;
  esac
done

if [ -z $1 ]
then
  printf "Error, this script requires flags to execute!\n"
  exit 1
fi

# Commit message variable
# MSG=$argM

# Return the aws account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Update the GitHub Actions workflows file
cp resources/terraform.yml .github/workflows/
sed -i "s/UPDATE_ME/$ACCOUNT_ID/g" .github/workflows/terraform.yml

# Return remote state s3 bucket name
BUCKET_NAME=$(aws s3 ls | grep terraform-remote-state | cut -d " " -f 3)
printf "BUCKET_NAME = $BUCKET_NAME\n"

# Update the main.tf file with the remote state s3 bucket
cp resources/main.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# Execute pipeline via pushing changes to the main branch
# git add .
# git commit -m $argM
# git push

$argP

# if [ -z $argP ]
# then
#   printf "argP exists...\n"
# #   exit 1
# fi