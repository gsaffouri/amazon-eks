#!/bin/bash -e

# Adds custom flag(s) to script
while getopts 'pm:f' OPTION; do
  case "$OPTION" in
    # Use this option to push changes to git
    p)
      argP="push"
      ;;
    # Use this option to enter a custom commit message
    m)
      argM="$OPTARG"
      ;;
    # This option is only for the CI GitHub Actions pipeline
    f)
      argF="fmt"
      ;;
    ?)
      echo "Usage: $(basename $0) [-p] [-m argument] [-f]"
      exit 1
      ;;
  esac
done

# Removes temporary files
./cleanup-tf.sh

# Default commit message if one is not provided via the 'm' flag
if [ -z "$argM" ]
then
  argM="Deploying resources..."
fi

if [ -n "$argF" ]
then
  # Copies main.tf file
  cp resources/main-local-backend.tf main.tf
fi

# Executes 'terraform apply' if the '-p' flag is used
if [ -n "$argP" ]
then
  # Return the aws account ID
  ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

  # Update the GitHub Actions workflows file
  cp resources/deployment.yml .github/workflows/
  sed -i "s/UPDATE_ME/$ACCOUNT_ID/g" .github/workflows/deployment.yml
  cp resources/destroy.yml .github/workflows/
  sed -i "s/UPDATE_ME/$ACCOUNT_ID/g" .github/workflows/destroy.yml

  # Return remote state s3 bucket name
  BUCKET_NAME=$(aws s3 ls | grep terraform-remote-state | cut -d " " -f 3)

  # Update the main.tf file with the remote state s3 bucket
  cp resources/main.tf main.tf
  sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

  # Push changes to main
  git add .
  git commit -m "$argM"
  git push
fi
