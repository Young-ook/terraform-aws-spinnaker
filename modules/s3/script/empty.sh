#!/bin/bash
# delete all object in a specific S3 bucket

CURDIR=`dirname $0`

function print_usage() {
  echo "Usage: $0 -b(bucket) <bucket-name> -r(region) <aws-region>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":b:r:" opt; do
    case $opt in
      b) BUCKET_NAME="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function empty() {
  aws s3api delete-objects \
    --region $AWS_REGION \
    --bucket $BUCKET_NAME \
    --delete "$(aws s3api list-object-versions \
      --region $AWS_REGION \
      --bucket $BUCKET_NAME \
      --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
      --output json)"

  echo $?
}

# main
process_args "$@"
empty
