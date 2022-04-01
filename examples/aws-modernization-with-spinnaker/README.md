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

![spinnaker-first-look](../../images/spinnaker-first-look.png)

🎉 Congrats, you’ve deployed the spinnaker on your kubernetes cluster.

## Application (Microservice)
An application is a microservice in spinnaker. When you log in to Spinnaker, there is a *Create Application* button in the upper right corner, click it to create a new application. And fill in the name and email fields. Enter your support name as *yelb* and your email address as Email.

![spinnaker-new-application](../../images/spinnaker-new-application.png)

### Pipeline
Automating the process of building and deploying an application is called a pipeline. Sometimes expressed as a workflow, but continuous delivery uses the term pipeline. Now let's move on to the next step and create our first pipeline.

#### Build
Build the container image using AWS CodeBuild. If the build is successful, the container image is saved to ECR and the Kubernetes manifest file is saved to the S3 bucket. The S3 bucket name is randomly added when Terraform creates it. If you look up the bucket in the S3 service, you will see a bucket with a name of the form *artifact-xxxx-yyyy*.

Now that we have created the **yelb** application, we need to create a pipeline within it. Enter a pipeline name by clicking *Create New Pipeline* that appears on the screen. Enter `build` and press *Create* to bring up a screen where you can edit your pipeline.

![spinnaker-pipeline-create](../..//images/spinnaker-pipeline-create.png)

Next, you can click *Add stage* to add to your pipeline. Choose *AWS CodeBuild* here. A space will then appear below where you can enter the necessary information for the build task.

![spinnaker-pipeline-codebuild-stage](../../images/spinnaker-pipeline-codebuild-stage.png)

Please enter the required information (The last 10 characters of the project name are anti-duplication serial automatically assigned by Terraform, and may vary depending on the situation).

 - **Account:** platform
 - **Project Name:** yelb-hello-xxxxx-yyyyy

![spinnaker-pipeline-build-project-name](../../images/spinnaker-pipeline-build-project-name.png)

Click *Save Changes* at the bottom of the screen to save.
After saving and verifying that your changes are reflected, click the End Pipeline arrow to navigate to the Edit Pipeline screen. At the top of the screen, there is a small arrow next to the pipeline name *build*.

After setting up your pipeline, click *Start Manual Execution* to run your pipeline. The CodeBuild project will start building, which will take about 2 minutes.

If the build is successful, enter the AWS console and go to the ECR service screen. The newly created container image appears. And go to the S3 service screen. The bucket list contains buckets with names of the form *artifact-xxxx-yyyy*. Press the appropriate bucket to get inside.

![spinnaker-s3-artifact-bucket](../../images/spinnaker-s3-artifact-bucket.png)

#### Base App
Deploy the container application with default settings. Deploy the database, cache, application server, and UI server. First, create a new pipeline. There is a Create Pipeline button in the upper right part of the screen. Enter `base-app-v1` as the pipeline name and apply. Click *Add stage* to select the type of stage. This time we are going to deploy, so we choose *Deploy (Manifest)* .

![spinnaker-pipeline-base-app-v1-deploy-stage](../../images/spinnaker-pipeline-base-app-v1-deploy-stage.png)

Select the required information. Select *eks* for Account and *Override Namespace* for Namespace and choose the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

![spinnaker-pipeline-base-app-v1-namespace](../../images/spinnaker-pipeline-base-app-v1-namespace.png)

Go to the S3 screen and pick the application settings file up you want to deploy. Navigate to the *artifact-xxxx-yyyy* bucket and select *1-base-app-v1.yaml* . When you get to a screen that displays detailed information about the object, tap the two small overlapping squares in front of the S3 object URI. Confirm the *S3 URI copied* popup and return to the spinnaker pipeline edit page.

![spinnaker-s3-artifact-bucket-copy-uri-base-app-v1](../../images/spinnaker-s3-artifact-bucket-copy-uri-base-app-v1.png)

Continue setting up your deployment environment.

+ Specifies the manifest source as an artifact.
    - **Manifest Source:** Artifact

+ Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *Define a new Artifact* appears. If you press to select, a screen for entering various additional information appears. Here, select *Account* as shown below. Just paste the S3 URI copied earlier into the *Object Path* part.

    - **Account:** platform
    - **Object Path:** s3://artifact-xxxx-yyyy/1-base-app-v1.yaml

![spinnaker-pipeline-base-app-v1-artifact-object](../../images/spinnaker-pipeline-base-app-v1-artifact-object.png)

Click *Save Changes* at the bottom of the screen to save.
After saving and confirming that the changes are reflected, click the exit pipeline arrow to move out of the pipeline editing screen. At the top of the screen, there is a small arrow next to the pipeline name that says *build*.

After setting up the pipeline, click *Start Manual Execution* to run the pipeline.

![spinnaker-pipeline-base-app-v1](../../images/spinnaker-pipeline-base-app-v1.png)

If the deployment is successful, click Clusters in the menu on the left side of the Spinnaker screen. Container information appears. Then, click Load Balancers in the navigation bar to display Kubernetes ingress and services. If you select Ingress, detailed information is displayed on the right side of the screen, and the access domain is displayed.

![spinnaker-pipeline-base-app-ingress-dns](../..//images/spinnaker-pipeline-base-app-ingress-dns.png)

#### Meshed App
In this step, we apply the service mesh (AWS App Mesh) to the base application. Create a new pipeline. There is a Create Pipeline button in the upper right corner of the screen. Enter `meshed-app-v1` as the pipeline name and press OK. Click *Add Step* to select a step type. This time we are going to deploy, so we choose *Deploy (Manifest)* .

Select the required information. Choose *eks* for Account, *Override Namespace* for Namespace, and select the list that starts with *hello*. (The last 10 characters of the Namespace are anti-duplication serial)

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

Go to the S3 screen and specify the application settings file to deploy. Navigate to the *artifact-xxxx-yyyy* bucket and select *2-meshed-app-v1.yaml*. When you get to a screen that displays detailed information about the object, tap the two small overlapping squares in front of the S3 object URI. Confirm the *S3 URI copied* popup and return to the spinnaker pipeline edit page.

Continue setting up your deployment environment.

 + Specifies the manifest source as an artifact.
    - **Manifest Source:** Artifact

 + Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *New Artifact Definition* appears. If you press to select, a screen for entering various additional information appears. Here, select *Account* as shown below. Just paste the S3 URI copied earlier into the *Object Path* part.
   - **Account:** platform
   - **Object Path:** s3://artifact-xxxx-yyyy/2-meshed-app-v1.yaml

Click *Save Changes* at the bottom of the screen to save. After saving and confirming that the changes are reflected, click the exit-pipeline-arrow to move out of the edit pipeline screen. At the top of the screen, there is a small arrow next to the pipeline name *build*.

After setting up your pipeline, click *Start Manual Execution* to run the pipeline.

#### Side-car Injection
We created a application mesh in App Mesh, but the application is still running as before. So we need to run *Rolling Restart* to force restart the pods. Sidecar proxies are also injected when the pods are restarted. Restart all DB, Redis, AppServer, UI (kubernetes) deployment displayed on the cluster screen. And wait a minute, then the v002 cluster will be created. If all 4 deployments become the v002, the restart is complete.

![spinnaker-deployment-rolling-restart](../../images/spinnaker-deployment-rolling-restart.png)

When the application shows as new version (v002), select the pod and press *Console Output* in the details view on the right side of screen. Then you can see the log of the container in the pod as shown below. When ENVOY and XRAY_DAEMON are displayed together, they are properly reflected.

![spinnaker-yelbv2-app-logs](../../images/spinnaker-yelbv2-app-logs.png)

#### Weighted Routing
Now deploy the new version of the application server. Deploy using the new container image created by the AWS CodeBuild pipeline. First, create a new pipeline. There is a Create Pipeline button in the upper right corner of the screen. Enter `meshed-app-v2` as the pipeline name and press OK. Click *Add Step* to select a stage type. This time we are going to deploy, so we choose *Deploy (Manifest)* .

Select the required information. Choose *eks* for Account, *Override Namespace* for Namespace, and select the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

Go to the S3 screen and specify the application settings file to deploy. Navigate to the *artifact-xxxx-yyyy* bucket and select *3-meshed-app-v2.yaml*. When you get to a screen that displays detailed information about the object, tap the two small overlapping squares in front of the S3 object URI. Confirm the *S3 URI copied* popup and return to the spinnaker pipeline edit page.

Continue setting up your deployment environment.

 + Specifies the manifest source as an artifact.
     - **Manifest Source:** Artifact

 + Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *New Artifact Definition* appears. If you press and select, a screen for entering various information appears. Here, select *Account* as shown below. Just paste the S3 URI copied earlier into the *Object Path* part.
     - **Account:** Platform
     - **object path:** s3://artifact-xxxx-yyyy/3-meshed-app-v2.yaml

Click *Save Changes* at the bottom of the screen to save. After saving and verifying that your changes are reflected, click the exit-pipeline-arrow to back to the pipelines screen. At the top of the screen, there is a small arrow next to the pipeline name *build*.

After setting up your pipeline, click *Start Manual Execution* to run your pipeline.

Even though a new version of the application is deployed, you can't access it even if you repeat 'refresh' on your web browser. This is because you only deploy containers and App Mesh doesn't direct traffic to the new version of the server. Now set it to send traffic to the new version of the application server as well. This example sets the traffic to be sent to the old server and the new version server at 50:50. Click the *Create Pipeline* button in the upper-right corner of the screen to create a new pipeline. Enter `weighted-route` as the pipeline name and press OK. Click *Add Step* to select a stage type. This time we are going to deploy, so we choose *Deploy (Manifest)* .

Select the required information. Choose *eks* for Account, *Override Namespace* for Namespace, and select the list that starts with *hello*.

 - **Account:** eks
 - **Namespace:** hello-xxxxx-yyyyy

Go to the S3 screen and specify the application settings file to deploy. Navigate to the *artifact-xxxx-yyyy* bucket and select *4-weighted-route.yaml*. When you get to a screen that displays detailed information about the object, tap the two small overlapping squares in front of the S3 object URI. Confirm the *S3 URI copied* popup and return to the spinnaker pipeline edit page.

Continue setting up your deployment environment.

 + Specifies the manifest source as an artifact.
     - **Manifest Source:** Artifact

 + Specify detailed settings for the manifest source. When you click the list next to *Manifest Artifact*, the text *New Artifact Definition* appears. If you press and select, a screen for entering various information appears. Here, select *Account* as shown below. Just paste the S3 URI copied earlier into the *Object Path* part.
     - **Account:** Platform
     - **object path:** s3://artifact-xxxx-yyyy/4-weighted-route.yaml

Click *Save Changes* at the bottom of the screen to save. After saving and verifying that your changes are reflected, click the exit-pipeline-arrow to back to the pipelines screen. At the top of the screen, there is a small arrow next to the pipeline name *build*.

After setting up your pipeline, click *Start Manual Execution* to run your pipeline.

![spinnaker-pipeline-weighted-route](../../images/spinnaker-pipeline-weighted-route.png)

Now, if you repeat 'refresh' in your web browser, you can see that the application server version displayed at the bottom of the screen has changed.

## Clean up
Run command:
```
./preuninstall.sh
terraform destroy --auto-approve
```
