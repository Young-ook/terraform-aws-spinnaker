#!/bin/bash -x

export KUBECONFIG=kubeconfig

${eks_update_kubeconfig}
kubectl delete ns ${eks_kubeconfig_context}

aws appmesh delete-mesh --mesh-name yelb-mesh --region ${aws_region}

rm kubeconfig

volumes=$(aws ec2 describe-volumes \
  --filters Name=tag:kubernetes.io/created-for/pvc/namespace,Values=spinnaker \
  --query "Volumes[*].{ID:VolumeId}" \
  --region ${aws_region} \
  --output text)

for volume in $volumes
do
  aws ec2 delete-volume --volume-id $volume --region ${aws_region}
done

unset KUBECONFIG
