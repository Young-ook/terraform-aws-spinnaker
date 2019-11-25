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

#
# create a spin-ui loadbalancer
function expose-ui () {
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
function expose-api () {
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
function expose-cli () {
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
function disable-cli () {
  kubectl delete svc spin-cli
}

# spinnaker loadbalancers to expose service
expose-ui

if [ $API_CLI = 'true' ]; then
expose-cli
expose-api ssl
else
disable-cli
expose-api http
fi

# clean up env
unset KUBECONFIG
