![ce-aks-tf](https://user-images.githubusercontent.com/104035488/175662346-237812d3-e248-43c8-9ac4-555b7c9fdc28.png)

# Calico Enterprise Trial Environment on AKS using Terraform


[![Tigera][tigera.io-badge]][tigera.io] [![Azure][azure-badge]][azure.link] [![Terraform][terraform-badge]][terraform.io]


This repository was built to accelerate the process of creating a Calico Enterprise trial environment. It provides the steps to create an AKS (Azure Kubernetes Service) cluster, deploying the the [Calico Enterprise](https://docs.tigera.io/about/about-calico-enterprise) product, and the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) as a example application, using Terraform.

## The Terraform Code

This section will guide you through the initial steps of setting up the needed environment for a Calico Enterprise demo using AKS.
The Terraform code presented here will build the following infrastructure:

- Create a Resource Group in Azure
- Create a AKS cluster with 3 nodes in the Resource Group
- Deploy and configure Calico Enterprise
- Deploy the Online Boutique application
- Create an output file with the needed information to access the environment

## Pre-requisites

To sucessfully deploy the Calico Enterprise product, you will need to provide the Terraform code with two important informations:
- The pull secret
- The license

For pulling images directly from `quay.io/tigera`, you will need to use the apropriate credentials License for the Calico Enterprise will be needed as well. If you don't have your credential and license yet, check [here](https://docs.tigera.io/getting-started/calico-enterprise) how to Get a license  or [contact us](https://www.tigera.io/contact/). Both files (credential and license) have to be stored in the tigera-secrets directory. Use the following names for each file:

- `config.json` (for the pull secret)
- `license.yaml` (for the license yaml)
 
```bash
mkdir tigera-secrets
cd tigera-secrets
vi config.json    # insert your pull secret in this file
vi license.yaml   # insert your license in this file
cd ..
```

Once you have the directory created and both files on it, you are ready to move to the next step.

>The following applications should be installed on your computer:
>- git
>- azure cli
>- terraform 
>- kubectl
>- k9s (optionally)

## Using Terraform to build the infrastucture

The Terraform code presented here will create the infrastructure to demonstrate the Calico Enterprise product. This module will explain how to run the Terraform code and what are the expected results:

1. Make sure that you created the `tigera-secrets` folder with the `config.json` and `license.yaml` files, as described in the [Pre-requisites](/README.md#pre-requisites) section.
By now, your working directory should look like the following:
```bash
$ tree
.
└── tigera-secrets
    ├── config.json
    └── license.yaml
$
```

> ❗️ Another importante pre-requisite is to have your Azure cli logged in the Azure account where you want to deploy the infrastructure.
>     
> ```bash
> az login
> ```


2. The next step is to clone this git repository:

```bash
git clone https://github.com/tigera-solutions/ce-aks-tf.git
```
After cloning the repository, your working directory will look like the following:

```bash
$ tree
.
├── ce-ob-aks-tf
│   ├── README.md
│   ├── application.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── tigera.tf
│   └── variables.tf
└── tigera-secrets
    ├── config.json
    └── license.yaml
```

3. Lets now initiate the Terraform in the `ce-aks-tf` directory.

```sh
terraform init
```

The output should be something like the bellow
```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "3.4.0"...
- Finding hashicorp/kubernetes versions matching "2.11.0"...
- Finding hashicorp/null versions matching "3.1.1"...
- Installing hashicorp/kubernetes v2.11.0...
- Installed hashicorp/kubernetes v2.11.0 (signed by HashiCorp)
- Installing hashicorp/null v3.1.1...
- Installed hashicorp/null v3.1.1 (signed by HashiCorp)
- Installing hashicorp/azurerm v3.4.0...
- Installed hashicorp/azurerm v3.4.0 (signed by HashiCorp)

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

4. Once the Terrafor has being successfully `ce-aks-tf` directory, you can apply the Terraform code.

```sh
terraform apply -auto-approve
```

Terraform will prompt asking for the `owner-name`. This variable will be used to prefix all the resources to be created in Azure, so make sure that you use a ease-to-identity value for this variable. e.g. your first name.

```sh
$ terraform apply -auto-approve
var.owner-name
  Enter a value: regis
```
Great! Now you just need to wait until Terraform finishes the infrastructure creation process.

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


