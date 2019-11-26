#!/bin/bash -e

##
# Environment variables
CURDIR=`dirname $0`
KUBE_HOME=$CURDIR/kube
HELM_HOME=$CURDIR/helm
NAMESPACES="spinnaker prometheus"

EKS_NAME=${cluster_name}
EKS_ARN=${cluster_arn}

export AWS_DEFAULT_REGION=${aws_region}
export KUBECONFIG=$KUBE_HOME/config

#
# Initialize kubernetes config file using aws cli
function init_kube() {
  # Make new home directory for kubernetes configuration
  if [ -d $KUBE_HOME ]; then
    rm -r $KUBE_HOME
  fi
  mkdir -p $KUBE_HOME

  # update kubeconfig
  aws eks update-kubeconfig --name $EKS_NAME

  # change the context of kubernetes cluster
  kubectl config use-context $EKS_ARN

  # register worker nodes to master
  cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${node_pool_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
}

#
# Initialize tiller on kubernetes
function init_tiller() {
  local NAMESPACE=$1
  local SERVICEACCOUNT=$NAMESPACE-tiller
  local CONTEXT=$SERVICEACCOUNT

  # configure minimal RBAC permissions for helm/tiller
  cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-manager
  namespace: $NAMESPACE
rules:
- apiGroups: ["", "batch", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-binding
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
roleRef:
  kind: Role
  name: tiller-manager
  apiGroup: rbac.authorization.k8s.io
EOF

  TOKEN=$(kubectl get secret \
           $(kubectl get serviceaccount $SERVICEACCOUNT \
            -n $NAMESPACE \
            -o jsonpath='{.secrets[0].name}') \
         -n $NAMESPACE \
         -o jsonpath='{.data.token}' | base64 --decode)

  kubectl config set-credentials $SERVICEACCOUNT --token $TOKEN
  kubectl config set-context $CONTEXT \
          --cluster=$EKS_ARN \
          --user=$SERVICEACCOUNT \
          --namespace=$NAMESPACE
}

#
# Mminify kubernetes config
function minify () {
  # Create a full copy
  kubectl config view --raw > $KUBECONFIG.full.tmp

  # Switch working context to target context
  kubectl --kubeconfig $KUBECONFIG.full.tmp config use-context $1

  # Minify
  kubectl --kubeconfig $KUBECONFIG.full.tmp \
    config view --flatten --minify > $KUBECONFIG

  # Restrict access
  chmod 600 $KUBECONFIG

  # Remove tmp
  rm $KUBECONFIG.full.tmp
}

#
# x509 certification
function gen_certs () {
  # Make new home directory for helm/tiller
  if [ -d $HELM_HOME ]; then
    rm -r $HELM_HOME
  fi
  mkdir -p $HELM_HOME

  # Password auto-generation
  PASSWD=$(pwgen 20 1)
  echo $PASSWD > $HELM_HOME/x509pass.secret | chmod 600 $HELM_HOME/x509pass.secret

  cat << EOF > openssl.conf.tmp
[ req ]
distinguished_name  = req_distinguished_name

[ req_distinguished_name ]

[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
EOF

  # Create new self-signed certificate authority (CA)
  openssl genrsa -out $HELM_HOME/ca.key 4096
  openssl req -new -x509 -days 365 -sha256 -key $HELM_HOME/ca.key -out $HELM_HOME/ca.crt \
    -config openssl.conf.tmp -extensions v3_ca \
    -subj "/C=KR/ST=SEL/L=SEL/O=tiller/OU=tiller/CN=tiller"

  rm openssl.conf.tmp

  openssl genrsa -out $HELM_HOME/tiller.key 4096
  openssl req -key $HELM_HOME/tiller.key -new -sha256 -out $HELM_HOME/tiller.csr \
    -subj "/C=KR/ST=SEL/L=SEL/O=tiller/OU=tiller/CN=tiller"

  openssl genrsa -out $HELM_HOME/helm.key 4096
  openssl req -key $HELM_HOME/helm.key -new -sha256 -out $HELM_HOME/helm.csr \
    -subj "/C=KR/ST=SEL/L=SEL/O=tiller/OU=tiller/CN=tiller"

  openssl x509 -req -CAcreateserial -days 365 \
    -CA $HELM_HOME/ca.crt -CAkey $HELM_HOME/ca.key \
    -in $HELM_HOME/tiller.csr -out $HELM_HOME/tiller.crt

  openssl x509 -req -CAcreateserial -days 365 \
    -CA $HELM_HOME/ca.crt -CAkey $HELM_HOME/ca.key \
    -in $HELM_HOME/helm.csr -out $HELM_HOME/helm.crt
}

#
# Initialize helm
function init_helm () {
  local NAMESPACE=$1
  local SERVICEACCOUNT=$NAMESPACE-tiller

  helm init \
    --tiller-tls \
    --tiller-tls-cert $HELM_HOME/tiller.crt \
    --tiller-tls-key $HELM_HOME/tiller.key \
    --tiller-tls-verify \
    --tls-ca-cert $HELM_HOME/ca.crt \
    --tiller-namespace $NAMESPACE \
    --service-account $SERVICEACCOUNT \
    --kubeconfig $KUBECONFIG \
    --home $HELM_HOME
}


# initialize kubernetes
init_kube

# generate new x509 ca for helm/tiller communication
gen_certs

#
# initialize helm/tiller
for namespace in $NAMESPACES; do
  init_tiller $namespace
  init_helm $namespace
done

##
# Clean up the environment variables
unset AWS_DEFAULT_REGION
unset KUBECONFIG
