#!/bin/bash -ex

export KUBECONFIG=spinnaker_kubeconfig

${spinnaker_update_kubeconfig}
mv kubeconfig spinnaker_kubeconfig

${halyard_kubectl_exec} hal config version edit --version ${spinnaker_version}

${halyard_kubectl_exec} hal config ci codebuild account add platform \
  --account-id ${aws_account_id} \
  --assume-role ${spinnaker_managed_aws_role} \
  --region ${aws_region}
${halyard_kubectl_exec} hal config ci codebuild enable

${halyard_kubectl_exec} hal config artifact s3 account add platform \
  --region ${aws_region}
${halyard_kubectl_exec} hal config artifact s3 enable

${eks_update_kubeconfig}
kubectl -n spinnaker cp kubeconfig cd-spinnaker-halyard-0:/home/spinnaker/.kube/
rm kubeconfig

${halyard_kubectl_exec} hal config provider kubernetes account add eks \
  --kubeconfig-file '/home/spinnaker/.kube/kubeconfig' \
  --context ${eks_kubeconfig_context} \
  --environment dev
${halyard_kubectl_exec} hal config provider kubernetes enable

${halyard_kubectl_exec} hal deploy apply

unset KUBECONFIG
