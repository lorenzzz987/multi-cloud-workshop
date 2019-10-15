# Lab 04 - Terraform #

### 1. Install Terraform ###

`sudo apt-get install unzip`
`wget https://releases.hashicorp.com/terraform/0.12.10/terraform_0.12.10_linux_amd64.zip`
`unzip terraform_0.12.10_linux_amd64.zip`
`sudo mv terraform /usr/local/bin/`
`terraform --version`

### 2. AWS configuration ###

click account bovenaan -> my security credentials -> create access key


edit variables.tf with keys
edit variables.tf instance name student number

NOT NEEDED ANYMORE, DEFINED IN variables.tf
`sudo apt-get instal awscli`
`aws configure`
key ID:  
Secret:  
region: eu-west-1
default output format: json
`aws ec2 describe-instances`

### 3. Gcloud configuration ###

# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
:
# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk

`glcoud auth application-default login`

open link, authorize, copy verification code


edit variabled.tf student number

ALTERNATIVE: use service account ( Downloads/gluo-sandbox-450764035ef3.json )  
export GOOGLE_CLOUD_KEYFILE_JSON="/home/jens/Downloads/gluo-sandbox-450764035ef3.json"

### 4. Azure configuration ###

We would need to create a service principal. but credentials have already been provided in azure/variables.tf.

edit variabled.tf student number
