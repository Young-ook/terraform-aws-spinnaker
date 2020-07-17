#!/bin/bash -e

CURDIR=`dirname $0`
KUBE_HOME=$HOME/.kube
HAL_HOME=$HOME/.hal
SECRET_HOME=$HOME/.secret

export KUBECONFIG=$KUBE_HOME/config

function print_usage() {
  echo "Usage: $0 up | destroy"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    case $key in
      up)
        init
        ;;
      destroy)
        destroy
        ;;
      *)
        >&2 echo "Unrecognized argument '$key'"
        exit -1
    esac
  done
}

# create a halyard container and copy config files
function init() {
  cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: halyard
spec:
  containers:
  - name: halyard
    image: gcr.io/spinnaker-marketplace/halyard:stable
    imagePullPolicy: IfNotPresent
    workingDir: /home/spinnaker
EOF

  while [ $(kubectl get po halyard -o jsonpath='{.status.containerStatuses[].ready}') == false ]; do
    sleep 3;
  done

  kubectl cp $KUBE_HOME halyard:.kube
  kubectl cp $HAL_HOME halyard:.hal
  kubectl cp $SECRET_HOME halyard:.secret

  # get an interactive shell to run halyard command
  kubectl exec -it halyard -- bash
}

# backup the latest config files and destroy halyard container
function destroy() {
  kubectl cp halyard:.hal $HAL_HOME
  kubectl delete po halyard
}

# main
process_args "$@"

unset KUBECONFIG
