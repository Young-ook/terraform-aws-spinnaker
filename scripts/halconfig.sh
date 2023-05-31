#!/bin/bash
# halyard interactive mode
set -e

CURDIR=`dirname $0`
EKS_NAME=eks

export AWS_REGION=us-east-1
export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -n(name) <eks-name> -r(region) <aws-region> -p(pod) <pod-name>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":n:a:r:k:p:" opt; do
    case $opt in
      n) EKS_NAME="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      k) KUBECONFIG="$OPTARG"
      ;;
      p) POD_NAME="$OPTARG"
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
  aws eks update-kubeconfig --name $EKS_NAME --region $AWS_REGION

  # restrict access
  chmod 600 $KUBECONFIG
}

function prompt() {
  kubectl -n spinnaker exec -it $POD_NAME -- bash
}

# main
process_args "$@"
init
prompt

unset AWS_REGION
unset KUBECONFIG
