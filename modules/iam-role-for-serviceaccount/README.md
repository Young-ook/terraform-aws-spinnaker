# IAM Role for Service Account with OIDC
With [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) on Amazon EKS clusters, you can associate an IAM role with a Kubernetes service account. This module creates a single IAM role which can be assumed by trusted resources using OpenID Connect federated users. For more information about creating OpenID Connect identity provider, please visit [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/spinnaker-managed-eks/README.md#Quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/examples/spinnaker-managed-eks/README.md)
