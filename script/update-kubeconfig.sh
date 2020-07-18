#!/bin/bash -e
# update/generate kubernetes config file to access eks cluster

CURDIR=`dirname $0`
EKS_NAME=eks

export AWS_DEFAULT_REGION=us-east-1
export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -n(name) <eks-name> -r(region) <aws-region>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":n:a:r:k:" opt; do
    case $opt in
      n) EKS_NAME="$OPTARG"
      ;;
      r) AWS_DEFAULT_REGION="$OPTARG"
      ;;
      k) KUBECONFIG="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function init() {
  if [ -e $KUBECONFIG ]; then
    rm $KUBECONFIG
  fi

  # update kubeconfig
  aws eks update-kubeconfig --name $EKS_NAME
}

# main
process_args "$@"
init

unset AWS_DEFAULT_REGION
unset KUBECONFIG
