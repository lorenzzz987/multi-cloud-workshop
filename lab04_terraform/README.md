# Lab 04 - Terraform #

In this lab we will be using (Terraform)[https://www.terraform.io/].

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

In this lab we will be using Terraform to allow us to use the same tool/language to deploy our application to all 3 public cloud providers.

## 1. Install Terraform ##

Before we can start using Terraform we need to install it, but before we can install Terraform we need to install an additional package.  In this lab we will be working from our management server again, so X.mgmt.gluo.cloud.

Install the unzip package (required to unzip the Terraform binary):

```
sudo apt-get install unzip
```

Download the zip package containing the Terraform binary:

```
wget https://releases.hashicorp.com/terraform/0.12.10/terraform_0.12.10_linux_amd64.zip
```

Now unzip the package:

```
unzip terraform_0.12.10_linux_amd64.zip
```

Move the binary to the correct location:

```
sudo mv terraform /usr/local/bin/
```

Verify that your installation of Terraform was successful:

```
terraform --version
```

## 2. AWS configuration ##

## 3. Gcloud configuration ##

## 4. Azure configuration ##
