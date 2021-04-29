#!/bin/bash
# delete all kubernetes resources for spinnaker

CURDIR=`dirname $0`

export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":k:" opt; do
    case $opt in
      k) KUBECONFIG="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function delete() {
  kubectl delete ns spinnaker
}

# main
process_args "$@"
delete

unset KUBECONFIG
