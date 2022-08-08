![ce-aks-tf](https://user-images.githubusercontent.com/104035488/175662346-237812d3-e248-43c8-9ac4-555b7c9fdc28.png)




[![Tigera][tigera.io-badge]][tigera.io] [![Azure][azure-badge]][azure.link] [![Terraform][terraform-badge]][terraform.io]


export now=$(date); terraform destroy -auto-approve; echo $now; date

aws-infra - ~ 5min
rancher-server - ~ 6min
rke-cluster - ~ 9min
export TF_VAR_aws_access_key_id=<aws_access_key_id>
export TF_VAR_aws_secret_access_key=<aws_secret_access_key>


online boutique - ~ 5min

https://github.com/GoogleCloudPlatform/microservices-demo

git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo
kubectl apply -f ./release/kubernetes-manifests.yaml

calico cloud - ~ 13 min


total - ~ 35min



# Calico Cloud Trial on Rancher using Terraform on AWS.

This repository was built to speed up the process of creating a Rancher server and a RKE cluster for Calico Cloud trial. It provides the steps to create a RKE (Rancher Kubernetes Engine) cluster through a Rancher server on AWS using EC2 instances. Also, you can find here the steps for deploying the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) as an example application, and connecting your cluster to Calico Cloud.

## The Terraform Code

This section will guide you through the initial steps of setting up a RKE cluster using Rancher on AWS EC2 instances.
The Terraform code presented here consists of a stack with 3 layers:
 
- AWS Infrastructure
- Rancher Server
- RKE Cluster

Each layer has a Terraform code for a specific task and it is built on the top of the previous layer. This layer segmentation will help if you want partially destroy the infrastructure later on.

## Pre-requisites

>The following applications should be installed on your computer:
>- git
>- aws cli
>- terraform 
>- kubectl
>- k9s (optionally)

## Using Terraform to build the infrastucture

This section will explain how to run the Terraform code and what are the expected results:

1. The next step is to clone this git repository:

```bash
git clone https://github.com/regismartins/cc-rancher-ec2-tf-stack.git
```
After cloning the repository, your working directory will look like the following:

```bash
cc-rancher-ec2-tf-stack
├── README.md
├── aws-infra
│   ├── aws_infra.tf
│   ├── data.tf
│   ├── outputs.tf
│   └── terraform.tf
├── common
│   ├── output.tf
│   └── variables.tf
├── rancher-server
│   ├── bootstrap.tf
│   ├── data.tf
│   ├── helm.tf
│   ├── k3s.tf
│   ├── output.tf
│   └── terraform.tf
└── rke-cluster
    ├── data.tf
    ├── output.tf
    ├── rke.tf
    ├── terraform.tf
    └── variables.tf
```

2. The variables to be used across all layers are in the the `variables.tf` in the `common` folder. They are loaded as a module.
The first step is to customize the variables for your environment.
The following table describes the variables:

| Variable | Description | Default Value |
| --- | --- | --- |
| owner | Name to be used in the Owner tag of the AWS resources | Regis Martins |
| prefix | The prefix will precede all the resources to be created for easy identification | regis |
| aws_region | AWS region to be used in the deployment | ca-central-1 |
| aws_az | AWS availability zone to be used in the deployment | b |
| vpc_cidr | VPC CIDR for the EC2 instances | 100.0.0.0/16 |
| instance_type | Instance type used for Rancher server EC2 instance | t3a.medium |
| hosted_zone | The hosted zone domain to be used for the Rancher server | tigera.rocks |
| domain_prefix |Domain prefix of the Rancher server. https://domain_prefix.hosted_zone (ie: https://rancher.tigera.rocks) | rancher |
| rancher_kubernetes_version | Kubernetes version to use for Rancher server cluster | v1.22.9+k3s1 |
| cert_manager_version | Version of cert-manager to install alongside Rancher (format: 0.0.0) | 1.7.1 |
| rancher_version | Rancher server version (format: v0.0.0) | 2.6.5 |
| admin_password | Password to be defined for the admin user by the bootstrap (12 char. minimum) | rancherpassword |
| workload_kubernetes_version | Kubernetes version to use for managed RKE cluster | v1.22.10-rancher1-1 | 
| rancher_cluster_name | Prefix for the RKE cluster| rke |
| aws_access_key_id | export TF_VAR_aws_access_key_id = <ACCESS_KEY> for the Rancher server to provision the RKE cluster | "" |
| aws_secret_access_key | export TF_VAR_aws_secret_access_key = <SECRET_KEY> for the Rancher server to provision the RKE cluster | "" |


After reviewing and customizing the variables, let's start applying the Terraform code beggining with the aws-infra, which will build the infrastructure on AWS.

### AWS Infrastructure (aws-infra)

The following elements will be created on AWS for the Rancher server installation:

- VPC
- Subnet
- Internet Gateway
- Default route
- Security Group
- TLS keys
- EC2 Instance
- Load Balancer
- Hosted Zone Record
- Certificate
- IAM role and policy

![aws-infra-rancher](https://user-images.githubusercontent.com/104035488/183460237-8ae29de1-3060-4f44-acd7-3c3c90ec2898.jpg)

1. Change to the `aws-infra` folder.

```sh
cd ./cc-rancher-ec2-tf-stack/aws-infra
```

2. Lets now initiate the Terraform in the `aws-infra` directory.

```sh
terraform init
```

The output should be something like the bellow
```sh
$ terraform init

Initializing modules...
- common in ../common

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "4.18.0"...
- Finding hashicorp/local versions matching "2.2.3"...
- Finding hashicorp/tls versions matching "3.4.0"...
- Installing hashicorp/aws v4.18.0...
- Installed hashicorp/aws v4.18.0 (signed by HashiCorp)
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing hashicorp/tls v3.4.0...
- Installed hashicorp/tls v3.4.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
$
```

3. Once the Terrafor has being successfully initialized in the `aws-infra` directory, you can apply the Terraform code.

```sh
terraform apply -auto-approve
```

Great! Now you just need to wait until Terraform finishes the infrastructure creation process. This process may take about 5 minutes, on average.
At the end, the outputs will be like:

You don't need to remember them. They will be referred by the next modules.

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

```sh
Outputs:

aws_iam_profile_name = "regis-rancher-profile"
aws_security_group = "regis-rancher-allow-all"
aws_subnet_id = "subnet-035c3d2350d89c030"
private_key = <sensitive>
rancher_server_private_ip = "100.0.14.233"
rancher_server_public_ip = "35.183.125.29"
rancher_url = "rancher.tigera.rocks"
vpc_id = "vpc-06e23cbacb3622e0d"

$
```

After all the resources has being successfully created, you can connect to the AWS console and check the resources that were created, if you will. They will have a prefix as you configured in the `variables.tf` file, in the common folder. Also, the following tags were included in all resources:

```text
Environment = "rancher-workshop"
Owner       = <owner_variable>
Terraform   = "true"
```

You can change or add more tags by editing the `terraform.tf` file in the `aws-infra` folder.

For the next step, let's apply the Terraform code to build a Rancher server using the AWS infrastructure deployed here.

### Rancher Server (rancher-server)

This piece of Terraform code will install a Kubernetes K3s cluster in the EC2  instance previously deployed and use Helm charts to install the Certificate Manager (https://artifacthub.io/packages/helm/cert-manager/cert-manager) and the Rancher server itself. The final step is to bootstrap the Rancher server, changing the admin password to the value of the variable `admin_password` speficied in the `variable.tf` file in the `common` folder.

1. Change to the `aws-infra` folder.

```sh
cd ../rancher-server
```

2. Lets now initiate the Terraform in the `rancher-server` directory.

```sh
terraform init
```

The output should be something like the bellow
```sh
$ terraform init

Initializing modules...
- common in ../common

Initializing the backend...

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding hashicorp/helm versions matching "2.5.1"...
- Finding rancher/rancher2 versions matching "1.24.0"...
- Finding hashicorp/local versions matching "2.2.3"...
- Finding loafoe/ssh versions matching "2.0.1"...
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing loafoe/ssh v2.0.1...
- Installed loafoe/ssh v2.0.1 (self-signed, key ID C0E4EB79E9E6A23D)
- Installing hashicorp/helm v2.5.1...
- Installed hashicorp/helm v2.5.1 (signed by HashiCorp)
- Installing rancher/rancher2 v1.24.0...
- Installed rancher/rancher2 v1.24.0 (signed by a HashiCorp partner, key ID 2EEB0F9AD44A135C)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
$
```

3. Once the Terrafor has being successfully initialized in the `aws-infra` directory, you can apply the Terraform code.

```sh
terraform apply -auto-approve
```

Great! Now you just need to wait until Terraform finishes the infrastructure creation process. This process may take about 5 minutes, on average.
At the end, the outputs will be like:

You don't need to remember them. They will be referred by the next modules.

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

```sh
Outputs:

aws_iam_profile_name = "regis-rancher-profile"
aws_security_group = "regis-rancher-allow-all"
aws_subnet_id = "subnet-035c3d2350d89c030"
private_key = <sensitive>
rancher_server_private_ip = "100.0.14.233"
rancher_server_public_ip = "35.183.125.29"
rancher_url = "rancher.tigera.rocks"
vpc_id = "vpc-06e23cbacb3622e0d"

$
```



















5. During the creation process, once Terraform finishes to create the AKS cluster, you can use [k9s](https://k9scli.io/) to monitor the pods creation during the Calico Enterprise installation

```sh
k9s -A
```
![k9s](https://user-images.githubusercontent.com/104035488/175186117-58ea5073-3b3a-468e-9c8c-ea781f2cad10.gif)

6. When the Terrafom has finished, the following output message will be displayed:

```sh
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

calico_portal = "Environment information can be find at ../tigera-secrets/secrets.txt"
$
```
A new file `secrets.txt` was created during the infrastructure creation. The `secrets.txt` file contains the information to access the Boutique Online application, the Calico Enterprise portal and the Kibana server.

```sh
$ cat ../tigera-secrets/secrets.txt
Online Boutique Portal:
url: http://52.226.209.201/

-------------------------------------------------
Calico Portal:
url: https://52.226.208.201:9443/
token : eyJhbGciOiJSUzI1NiIsImtpZCI6InFsNEJ0dk5sZUFBdnAzdnJ0T2tYTnRRdHBFamdzQUthZjk4Z25XX0pwXzQifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InJlThisisnotarealtokenitsjustanexamplet9CwSojNc-7ah6Yvj7gAqHZ55pVSk8td7pKrdP9VpWJ9sZ2OiUpGCQ3UCIpATSnIk3zGeXK2jmaHEQzjdquOoJljfeJhgDLRHclwFiOHyR5Rv6P6XyWhSaWgALwcvbR5Dm_-I1RvUfTlkVQn3iEB4FtrZGPl9s5esY_rw58XjkZ6R5OvRCm1Y2npb7GpI1oCzmJ0CzuYUsCCupqHPN2XtrI6NYsAx3isHalnVZaLPsA9gCBW-NcmANhNG-a5pL_mZaivrjctFoA_RQOxA3G-LQeF9ZMf6Neod11ZIV9MQvfKFq_pk2UJuUAnhcfHTzZjFmZKq2-KczGbkvNi6Avcbjf238Fd-lsFD1-AWhY83zp2iqB7MDMNfc4nwC-qhZxBG5PAiO-QHJ-dFuTbwcqmXL7p47oxA5xzar9-bW77r_a_8WivFAkEg5G2B-HBqiHHlLhU9-YFybr9whNKI3S0U23xNrglNlycUeaQDIYhDGD5Zh4c

-------------------------------------------------
kibana
username: elastic
password: 3Qpr460XFaKEqQEf5v0cGZ2w
$
```

>Note: As the last step in Terraform code is to create the Boutique Online application, it may take a few minutes to became available.

Test the access to each one of the services. If it is working, you will be able to see the following:

Online Boutique:

![boutique](https://user-images.githubusercontent.com/104035488/170888988-a4a12bfd-dcaa-4708-bc24-aa884c3c514d.png)

Calico Portal login

![calico_portal](https://user-images.githubusercontent.com/104035488/170889002-6d559a39-f0df-4705-84b2-649f5df685c1.gif)

Kibana

![kibana](https://user-images.githubusercontent.com/104035488/170889006-cb13e757-7ac0-4159-b768-30ed6bc33fe1.gif)

Congratulations! You have everything in place to start testing the Calico's Enterprise features.

## Housekeeping

Once you are done with the trial, you can delete the whole environment using the following commnad:

```bash
terraform  destroy -auto-approve
```

---

## Customizing your deployment

There are a few parameters that are tied to variables and can be easly configured:

### prefix

The prefix is used on you Resource Group and AKS cluster nomenclature. 

```terraform
variable "prefix" {
  type    = string
  default = "ce-aks-tf"
}
```
You can customize it when running the terraform apply:

```bash
terraform apply -var="prefix=<your_custom_prefix>"
```

### location

In the same way, you can choose to deploy your cluster in a different region than East US (default).

```terraform
variable "location" {
  type    = string
  default = "East US"
}
```

A list of the available regions variable values can be found [here](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview#azure-regions-with-availability-zones).

```bash
terraform apply -var="location=<your_custom_location>"
```

### vm-size

Also, if you will, you can select another vm size for the nodes in the cluster. The default vm size is the Standard_D11_v2, which attends the [minimun requirements](https://docs.tigera.io/getting-started/kubernetes/requirements#network-requirements) for the nodes.  

```terraform
variable "vm-size" {
  type    = string
  default = "Standard_D11_v2"
```

A list of all available vm sizes can be found [here](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes).

```bash
terraform apply -var="vm-size=<your_custom_vm_size>"
```

---

[⬆️ Back to the top](https://github.com/regismartins/ce-aks-tf) 

---

[tigera.io-badge]: https://img.shields.io/badge/Powered%20by-Tigera-orange
[tigera.io]: https://www.tigera.io
[terraform.io-badge]: https://img.shields.io/badge/Powered%20by-Terraform-purple
[terraform.io]: https://www.terraform.io
[terraform-badge]: https://img.shields.io/badge/-Terraform-7b3fc4?style=?style=flat-square&logo=terraform&logoColor=white
[azure-badge]: https://img.shields.io/badge/-Azure-257bc2?style=?style=flat-square&logo=microsoftazure&logoColor=white
[azure.link]: https://azure.microsoft.com


