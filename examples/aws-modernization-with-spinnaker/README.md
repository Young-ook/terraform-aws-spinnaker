[[English](README.md)] [[한국어](README.ko.md)]
# AWS Application Modernization with Spinnaker

![aws-modernization-with-spinnaker](../../images/aws-modernization-with-spinnaker-architecture.png)

## Prerequisites
We use [Terraform](https://terraform.io), and [Kubernetes](https://kubernetes.io/) in this lab. Please visit the main [page](https://github.com/Young-ook/terraform-aws-spinnaker#terraform) and follow the installation instructions if you don't have terraform cli (command-line interface) in your workspace. And also, make sure that you have kubernetes cli. Here is the official web [page](https://kubernetes.io/docs/tasks/tools/#kubectl) and follow the instructions to install kubernetes cli.

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

![spin-first-look](../../images/spin-first-look.png)

🎉 Congrats, you’ve deployed the spinnaker on your kubernetes cluster.

## Application (Microservice)
An application is a microservice in spinnaker. When you log in to Spinnaker, there is a *Create Application* button in the upper right corner, click it to create a new application. And fill in the name and email fields. Enter your application name as *yelb* and your email address as Email.

![spin-yelb-new-app](../../images/spin-yelb-new-app.png)

### Service Mesh Pipeline
Automating the process of building and deploying an application is called a pipeline. Sometimes expressed as a workflow, but continuous delivery uses the term pipeline. Now let's move on to the next step and create our first pipeline.

Now that we have created the **yelb** application, we need to create a pipeline within it. Enter a pipeline name by clicking *Create New Pipeline* that appears on the screen. Enter `service-mesh` and press *Create* to bring up a screen where you can edit your pipeline.

![spin-yelb-new-pipe-svc-mesh](../../images/spin-yelb-new-pipe-svc-mesh.png)

#### Build Stage
In this lab, we build the container image using AWS CodeBuild. If the build is successful, the container image is saved to ECR and the Kubernetes manifest file is saved to the S3 bucket. The S3 bucket name is randomly added when Terraform creates it. If you look up the bucket in the S3 service, you will see a bucket with a name of the form *artifact-xxxx-yyyy*. Please note the bucket name separately as it is required for pipeline setup.

To add a build step to the pipeline, you can click *Add Stage*. Choose *AWS CodeBuild* here. A space will then appear below where you can enter the necessary information for the build task.

![spin-yelb-pipe-build-stage](../../images/spin-yelb-pipe-build-stage.png)

Please enter the required information (The last 10 characters of the project name are anti-duplication serial automatically assigned by Terraform, and may vary depending on the situation).

 - **Account:** platform
 - **Project Name:** yelb-hello-xxxxx-yyyyy

![spin-yelb-pipe-build-proj](../../images/spin-yelb-pipe-build-proj.png)

Click *Save Changes* at the bottom of the screen to save. Verfy your changes are reflected properly.

#### Deploy Base Application Stage
Deploy the container application with default settings. Deploy the database, cache, application server, and UI server. In this step, we also apply the service mesh (AWS App Mesh) to the base application. Click *Add stage* to select the type of stage. This time we are going to deploy, so we choose *Deploy (Manifest)* .

![spin-yelb-pipe-deploy-stage](../../images/spin-yelb-pipe-deploy-stage.png)

Select the required information. Select *eks* for Account and *Override Namespace* for Namespace and choose the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

![spin-yelb-pipe-app-ns](../../images/spin-yelb-pipe-app-ns.png)

Continue setting up your deployment environment.

+ Specifies the manifest source as an artifact.
    - **Manifest Source:** Artifact

+ Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *Define a new Artifact* appears. If you press to select, a screen for entering various additional information appears. Here, select *Account* as shown below. And, fill out the *Object Path* field with the full S3 URI of `1.app-v1.yaml` file.

    - **Account:** platform
    - **Object Path:** s3://artifact-xxxx-yyyy/1.app-v1.yaml

![spin-yelb-pipe-app-v1](../../images/spin-yelb-pipe-app-v1.png)

We design the pipeline to wait a while before moving on to the next step of deployment stage. To add an approval process, click *Add Step* and then select *Manual Judgment*.

![spin-yelb-pipe-judgment-stage](../../images/spin-yelb-pipe-judgment-stage.png)

Click *Save Changes* at the bottom of the screen to save. Verfy your changes are reflected properly.

#### Deploy New Application Stage
Now configure the pipeline stage to deploy the new version of the application server. Deploy using the new container image created by the AWS CodeBuild pipeline. Click *Add Stage* to select a stage type. This time we are going to deploy, so we choose *Deploy (Manifest)* .

Select the required information. Choose *eks* for Account, *Override Namespace* for Namespace, and select the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

Continue setting up your deployment environment.

 + Specifies the manifest source as an artifact.
     - **Manifest Source:** Artifact

 + Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *New Artifact Definition* appears. If you press and select, a screen for entering various information appears. Here, select *Account* as shown below. And, fill out the *Object Path* field with the full S3 URI of `2.app-v2.yaml` file.

     - **Account:** Platform
     - **object path:** s3://artifact-xxxx-yyyy/2.app-v2.yaml

![spin-yelb-pipe-app-v2](../../images/spin-yelb-pipe-app-v2.png)

We design the pipeline to wait a while before moving on to the next step of deployment stage. To add an approval process, click *Add Step* and then select *Manual Judgment*.

Click *Save Changes* at the bottom of the screen to save. Verfy your changes are reflected properly.

#### Weighted Route Stage
After the approval step has been added, add a new stage to apply the weighted route configuration. Click *Add Stage* to select a stage type. This time we are going to deploy, so we choose *Deploy (Manifest)* .

Select the required information. Choose *eks* for Account, *Override Namespace* for Namespace, and select the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

Continue setting up your deployment environment.

 + Specifies the manifest source as an artifact.
     - **Manifest Source:** Artifact

 + Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *New Artifact Definition* appears. If you press and select, a screen for entering various information appears. Here, select *Account* as shown below. And, fill out the *Object Path* field with the full S3 URI of `3.weighted-route.yaml` file.

     - **Account:** Platform
     - **object path:** s3://artifact-xxxx-yyyy/3.weighted-route.yaml

![spin-yelb-pipe-app-wr](../../images/spin-yelb-pipe-app-wr.png)

Click *Save Changes* at the bottom of the screen to save. Verfy your changes are reflected properly.

### Run Pipeline
After saving and verifying that your changes are reflected, click the *End Pipeline* arrow to navigate to the Edit Pipeline screen. At the top of the screen, there is a small arrow next to the pipeline name *service-mesh*.

After setting up your pipeline, click *Start Manual Execution* to run your pipeline. The CodeBuild project will start building, which will take about 2 minutes.

If the build is successful, enter the AWS console and go to the ECR service screen. The newly created container image appears. And go to the S3 service screen. The bucket list contains buckets with names of the form *artifact-xxxx-yyyy*. Press the appropriate bucket to get inside. You will see the build results.

![aws-s3-artifact-manifest](../../images/aws-s3-artifact-manifest.png)

If the deployment is successful, click Clusters in the menu on the left side of the Spinnaker screen. Container information appears. Select the pod and press *Console Output* in the details view on the right side of screen. Then you can see the log of the container in the pod as shown below. When ENVOY and XRAY_DAEMON are displayed together, they are properly reflected.

![spin-yelb-app-pod](../../images/spin-yelb-app-pod.png)
![spin-yelb-app-logs](../../images/spin-yelb-app-logs.png)

Then, click Load Balancers in the navigation bar to display Kubernetes ingress and services. If you select Ingress, detailed information is displayed on the right side of the screen, and the access domain is displayed. Click the displayed load balancer DNS name to open the application in a new tab or window. You can see the application is working properly.

![spin-yelb-app-ing](../../images/spin-yelb-app-ing.png)

The pipeline has only performed the first deployment, and is waiting in the approval stage before proceeding to the next stage of deploying a new version of the application. Once you have verified that the base application is working well, proceed to the next step. Press the *Continue* button to deploy a new version of the application server.

![spin-yelb-pipe-judge-v1](../../images/spin-yelb-pipe-judge-v1.png)

Even though a new version of the application is deployed, you can't access it even if you repeat 'refresh' on your web browser. This is because you only deploy containers and App Mesh doesn't direct traffic to the new version of the server. Now set it to send traffic to the new version of the application server as well. This example sets the traffic to be sent to the old server and the new version server at 50:50. When the new application deployment task is complete, a request approval popup appears. This is the process of waiting a while before applying weighted traffic control. Press the *Continue* button to move forward. 

![spin-yelb-pipe-judge-v2](../../images/spin-yelb-pipe-judge-v2.png)

Now, if you repeat 'refresh' in your web browser, you can see that the application server version displayed at the bottom of the screen has changed.

![spin-yelb-pipe-exec-complete](../../images/spin-yelb-pipe-exec-complete.png)

## Observability
Let’s see if the application works. In this workshop, Container Insights(Metrics, Logs) and X-Ray(Trace) agents are already installed and enabled. Move to the CloudWatch service page on the AWS Console for monitoring. You can see metrics and trace map when you select *Container Insights* or *Service Lens* menu on the navigation bar. Here are screenshots of observability example.

![aws-cw-metrics-dashboard](../../images/aws-cw-metrics-dashboard.png)
![aws-xray-topology](../../images/aws-xray-topology.png)
![aws-xray-timeline](../../images/aws-xray-timeline.png)

## Clean up
On the screen port-forward logs are shown. Press *ctrl + c* keys to exit port-forward process. Next, run commands:
```
./preuninstall.sh
terraform destroy --auto-approve
```

It may take servral menuites until delete whole Kubernetes resources including namespace from your cluster. Next, Go to the AWS Management Console and get to CloudWatch service page. Select Log groups on the navigation bar on the left of the screen. Enter `hello` for filtering. When log groups start form '/aws/codebuild', '/aws/containerinsights/' appear, choose them and delete like belows.

![aws-cw-delete-log-groups](../../images/aws-cw-delete-log-groups.png)

## Additional Resources
- [Terraform module: Amazon EKS](https://registry.terraform.io/modules/Young-ook/eks/aws/latest)
- [Terraform module: Amazon VPC](https://registry.terraform.io/modules/Young-ook/vpc/aws/latest)
- [Terraform module: AWS FIS](https://registry.terraform.io/modules/Young-ook/fis/aws/latest)
- [Terraform module: AWS IAM](https://registry.terraform.io/modules/Young-ook/passport/aws/latest)
- [Terraform module: Terraform Backend](https://registry.terraform.io/modules/Young-ook/tfstate-backend/aws/latest)
