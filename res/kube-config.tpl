#!/bin/bash -xe

# env
export AWS_PROFILE=${aws_profile}
export AWS_DEFAULT_REGION=${aws_region}
export KUBECONFIG=./config-${cluster_name}

###
# initialize kubernetes config file using aws cli
###
function init-kubeconfig () {
  # update kubeconfig
  aws eks update-kubeconfig --name ${cluster_name}

  # change the context of kubernetes cluster
  kubectl config use-context ${cluster_arn}

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


###
# create service-account
###
function service-account () {
  CTX=${cluster_name}
  SA=${cluster_name}-sa
  NS=spinnaker

  # create a service account and namespace
  kubectl describe namespace $NS && echo "Namespace already exists" || kubectl create namespace $NS

  cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SA
  namespace: $NS
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: spinnaker
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $SA
  namespace: $NS
EOF

  TOKEN=$(kubectl get secret \
           $(kubectl get serviceaccount $SA \
            -n $NS \
            -o jsonpath='{.secrets[0].name}') \
         -n $NS \
         -o jsonpath='{.data.token}' | base64 --decode)

  kubectl config set-credentials $SA --token $TOKEN
  kubectl config set-context $CTX \
          --cluster=${cluster_arn} \
          --user=$SA \
          --namespace=$NS
  kubectl config use-context $CTX

  # make a minified kubeconfig
  minify $CTX
}


###
# minified kubernetes config
###
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

# initialize kubernetes config and create a service account
init-kubeconfig
service-account

# clean up env
unset AWS_PROFILE
unset AWS_DEFAULT_REGION
unset KUBECONFIG
