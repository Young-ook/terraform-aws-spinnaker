#!/bin/bash -e

##
# Environment variables
CURDIR=`dirname $0`
KUBE_HOME=$CURDIR/kube
SERVICEACCOUNT=tiller-account
NAMESPACE=spinnaker

## Conditions
API_CLI=false
API_SSL=false

export KUBECONFIG=$KUBE_HOME/config

# check kubernetes configuration
function check_kubeconf () {
  if [ ! -f $KUBECONFIG ]; then
    echo "Can not find kubernetes config"
    exit -1
  fi
}

# print help
function print_usage() {
  echo "Usage: lb.sh --api_only | --all | --clean"
}

# command parsing
function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    case $key in
      --all)
        API_CLI=true
        API_SSL=true
        ;;
      --api_only)
        API_CLI=false
        API_SSL=false
        ;;
      --clean)
        cleanup
        exit 0
        ;;
      *)
        >&2 echo "Unrecognized argument '$key'"
        exit -1
    esac
  done
}

#
# create a spin-ui loadbalancer
function expose_ui () {
  # create ui loadbalancer
  cat  << EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: spin-ui
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: "${elb_sec_policy}"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${ssl_cert_arn}
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
  labels:
    app: spin
    cluster: spin-deck
spec:
  ports:
  - name: ui
    port: 443
    targetPort: 9000
  selector:
    app: spin
    cluster: spin-deck
  type: LoadBalancer
EOF
}

#
# create a spin-api loadbalancer
function expose_api () {
  cat  << EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: spin-api
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: $1
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: "${elb_sec_policy}"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${ssl_cert_arn}
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
  labels:
    app: spin
    cluster: spin-gate
spec:
  ports:
  - name: api
    port: 443
    targetPort: 8084
  selector:
    app: spin
    cluster: spin-gate
  type: LoadBalancer
EOF
}

#
# create a spin-cli loadbalancer
function expose_cli () {
  cat  << EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: spin-cli
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  labels:
    app: spin
    cluster: spin-gate
spec:
  ports:
  - name: cli
    port: 443
    targetPort: 8085
  selector:
    app: spin
    cluster: spin-gate
  type: LoadBalancer
EOF
}

#
# delete the spin-cli loadbalancer
function disable_cli () {
  kubectl delete svc spin-cli
}

#
# delete all loadbalancers
function cleanup () {
  kubectl delete svc spin-api
  kubectl delete svc spin-cli
  kubectl delete svc spin-ui
}

### main
check_kubeconf
process_args "$@"

if $API_CLI && $API_SSL; then
  expose_api ssl
  expose_cli
  expose_ui
else
  disable_cli
  expose_api http
  expose_ui
fi

# clean up env
unset KUBECONFIG
