#!/bin/bash -e

CURDIR=`dirname $0`
KUBE_HOME=$CURDIR/kube
NAMESPACES="spinnaker prometheus"

EKS_NAME=${cluster_name}
EKS_ARN=${cluster_arn}

export AWS_DEFAULT_REGION=${aws_region}
export KUBECONFIG=$KUBE_HOME/config

function init() {
  # Make new home directory for kubernetes configuration
  if [ -d $KUBE_HOME ]; then
    rm -r $KUBE_HOME
  fi
  mkdir -p $KUBE_HOME

  # update kubeconfig
  aws eks update-kubeconfig --name $EKS_NAME
  kubectl config use-context $EKS_ARN

  for namespace in $NAMESPACES; do
    init_ns $namespace
  done

  minify $EKS_ARN
  rm $KUBECONFIG
}

function init_ns() {
  local NAMESPACE=$1
  local SERVICEACCOUNT=$NAMESPACE-sa
  local CONTEXT=$NAMESPACE

  # Minimal RBAC permissions for namespace
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
  name: $NAMESPACE-manager
  namespace: $NAMESPACE
rules:
- apiGroups: ["", "batch", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $NAMESPACE-binding
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
roleRef:
  kind: Role
  name: $NAMESPACE-manager
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

  minify $NAMESPACE
}

function minify () {
  local MINI_KUBECONFIG

  if [ $1 == $EKS_ARN ]; then
    MINI_KUBECONFIG=$KUBECONFIG-$EKS_NAME
  else
    MINI_KUBECONFIG=$KUBECONFIG-$1
  fi

  kubectl config view --raw > $KUBECONFIG.full.tmp
  kubectl --kubeconfig $KUBECONFIG.full.tmp config use-context $1
  kubectl --kubeconfig $KUBECONFIG.full.tmp \
    config view --flatten --minify > $MINI_KUBECONFIG

  chmod 600 $KUBECONFIG
  rm $KUBECONFIG.full.tmp
}

#
# initialize the minified kubeconfig files
#
init

unset AWS_DEFAULT_REGION
unset KUBECONFIG
