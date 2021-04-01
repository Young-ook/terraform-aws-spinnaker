# Amazon EKS (Elastic Kubernetes Service)
[Amazon EKS](https://aws.amazon.com/eks/) is a fully managed Kubernetes service. Customers trust EKS to run their most sensitive and mission critical applications because of its security, reliability, and scalability. This module will create a spinnaker managed EKS including control plane and data plane. And it gives you a utility bash script to configure RBAC on the EKS cluster. And users can configure an IAM Role for Kubernetes Service Account using terraform module. It is an important part to strengthen security by minimizing access permission of Kubernetes Pods. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [IRSA(IAM Role for Service Account](https://github.com/Young-ook/terraform-aws-eks/blob/main/modules/iam-role-for-serviceaccount/README.md).

## Quickstart
### Setup
```hcl
module "eks" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks"
  version = ">= 2.0"
  name    = "example"
}
```
Run terraform:
```
terraform init
terraform apply
```
After then you will see the created EKS cluster and node groups.

## Generate kubernetes config
This terraform module provides users a shell script that extracts the kubeconfig file of the EKS cluster. For more details, please visit the [terraform eks module](
https://github.com/Young-ook/terraform-aws-eks/blob/main/README.md#generate-kubernetes-config).
Prepare the kubeconfig file with credentials to access the EKS cluster using the script described above. This is important when activating your Kubenetes account in the next step.

## Store kubernetes config
Upload the kubeconfig file received from the script describe in the previous step to the S3 bucket that is created by this terraform module. It may look like below.
```
aws s3 cp kubeconfig s3://spinnaker-dev-tc1-xyzbc/
```

## Using S3 as a persistent storage
```
kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 -- bash
bash $ hal config storage s3 edit --region ap-northeast-2 --bucket spinnaker-dev-tc1-xyzbc
bash $ hal config storage edit --type s3
bash $ hal deploy apply
```

## Enabling Kubernetes account in spinnaker
This is an example code to enable Kubernetes account in the spinnaker. In this example `eks-test` is the name of the Kubernetes account in spinnaker. Please note that Kubernetes account uses the credential from a Kubernetes config file. Don't forget replace context and kubeconfig-file parameters with yours.
```
kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 -- bash
bash $ hal config provider kubernetes account add eks-test \
         --kubeconfig-file 'encryptedFile:s3!r:ap-northeast-2!b:spinnaker-dev-tc1-xyzbc!f:kubeconfig' \
         --context eks-test \
         --environment dev \
bash $ hal config provider kubernetes enable
bash $ hal deploy apply
```
For more information, please refer to [this](https://spinnaker.io/setup/install/providers/kubernetes-v2/).

## More information
- [Configuration S3 Storage](https://spinnaker.io/setup/install/storage/s3/)
- [Secrets Management in Halyard](https://spinnaker.io/reference/halyard/secrets/)
- [Halyard Command for Kubernetes Account Management](https://spinnaker.io/reference/halyard/commands/#hal-config-provider-kubernetes-account-add)
