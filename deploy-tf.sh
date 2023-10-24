#!/bin/bash -e

# Adds custom flag(s) to script
while getopts 'm:p' OPTION; do
  case "$OPTION" in
    # Use this option to enter a custom commit message
    m)
      argM="$OPTARG"
      ;;
    # Use this option to push changes to git
    p)
      argP="push"
      ;;
    ?)
      echo "Usage: $(basename $0) [-m argument] [-d]"
      exit 1
      ;;
  esac
done

# Return the aws account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Update the GitHub Actions workflows file
cp resources/terraform.yml .github/workflows/
sed -i "s/UPDATE_ME/$ACCOUNT_ID/g" .github/workflows/terraform.yml

# Return remote state s3 bucket name
BUCKET_NAME=$(aws s3 ls | grep terraform-remote-state | cut -d " " -f 3)

# Update the main.tf file with the remote state s3 bucket
cp resources/main.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# If -p flag is used, execute pipeline via pushing changes to the main branch
if [ -n "$argP" ]
then
  git add .
  git commit -m "$argM"
  git push
fi
