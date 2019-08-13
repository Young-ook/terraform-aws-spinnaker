#!/bin/bash -xe

# env
export KUBECONFIG=./config-${cluster_name}

# conditions
SPIN_CLI=false
API_SSL=false

# change the context of kubernetes cluster
kubectl config use-context ${cluster_name}

###
# create a spin-ui loadbalancer
###
function create-ui-lb () {
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

###
# create a spin-api loadbalancer
###
function create-api-lb () {
  # create api loadbalancer
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

###
# create a spin-cli loadbalancer
###
function create-cli-lb () {
  # create api loadbalancer
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

# spinnaker loadbalancers to expose service
create-ui-lb

if [ $API_SSL = 'true' ]; then
create-api-lb ssl
else
create-api-lb http
fi

if [ $SPIN_CLI = 'true' ]; then
create-cli-lb
fi

# clean up env
unset KUBECONFIG
