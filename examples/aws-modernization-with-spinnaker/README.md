[[English](README.md)] [[한국어](README.ko.md)]
# AWS Application Modernization with Spinnaker

![aws-modernization-with-spinnaker](../../images/aws-modernization-with-spinnaker-architecture.png)

## Setup
This is an aws modern application with hashicorp and spinnaker. The [main.tf](main.tf) is the terraform configuration file to create network infrastructure and kubernetes cluster, and spinnaker on your AWS account.

Run terraform:
```
terraform init
terraform apply -target module.foundation
```

To set up DevOps platform to another VPC, run below command:
```
terraform apply -target module.platform
```

## Access Spinnaker
Halyard is a command-line administration tool that manages the lifecycle of your spinnaker deployment, including writing & validating your deployment’s configuration, deploying each of spinnaker’s microservices, and updating the deployment. All production-capable deployments of spinnaker require halyard in order to install, configure, and update spinnaker. To install spinnaker using halyard, run script:
```
./halconfig.sh
```

After installation and configuration is complete, start port-forwarding through the kubernetes proxy.
```
./tunnel.sh
```
Open `http://localhost:8080` on a web browser. Or if your are running this example in Cloud9, click `Preview` and `Preview Running Application`. This opens up a preview tab and shows the spinnaker application.

![spinnaker-first-look](../../images/spinnaker-first-look.png)

🎉 Congrats, you’ve deployed the spinnaker on your kubernetes cluster.

## Spinnaker Pipelines
### Spinnaker Application (Microservice)
When you log in to Spinnaker, there is a *Create Application* button in the upper right corner, click it to create a new application. And fill in the name and email fields. Enter your support name as *yelb* and your email address as Email.

### Base App
### Meshed App
### Weighted Routing

## Clean up
Run command:
```
./preuninstall.sh
terraform destroy --auto-approve
```
