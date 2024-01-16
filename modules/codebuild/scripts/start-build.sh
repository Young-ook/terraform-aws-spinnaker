#!/bin/bash
CURDIR=`dirname $0`
PROJNAME=codebuild
STATUS="IN_PROGRESS"

export AWS_REGION=us-east-1

function print_usage() {
  echo "Usage: $0 -n(name) <project-name> -r(region) <aws-region>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":n:a:r:k:s:" opt; do
    case $opt in
      n) PROJNAME="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function build () {
  ID=$(aws codebuild start-build --region ${AWS_REGION} --output text --query 'build.id' --project-name ${PROJNAME})
  echo "Build ID: ${ID}"

  while [ ${STATUS} == "IN_PROGRESS" ]
  do
    STATUS=$(aws codebuild batch-get-builds --region ${AWS_REGION} --output text --query 'builds[*].buildStatus' --ids ${ID})
    echo "Build STATUS: ${STATUS}"
    sleep 30
  done
}

# main
process_args "$@"
build

unset AWS_REGION
exit 0
