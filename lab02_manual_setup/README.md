# Lab 02 - Manual Setup #

In this lab we will do everyting manually:

1. we will create a VM
1. we will create a DNS record (A-record) which we will point to the public IP of the VM
1. we will run a little script that will first install Docker and afterwards will start the multi-cloud-app container
1. we will verify that everything works by visiting the application in our browser

NOTE: please follow the instruction on the screen carefully, should you run behind let one of the instructors know!

## 1. AWS ##

* Create a VM: t2.micro
* Create a DNS record: X-manual.aws.gluo.cloud
* Run the script: `curl -fsSL https://raw.githubusercontent.com/gluobe/multi-cloud-workshop/master/lab02_manual_setup/setup | sh`
* Visit website: http://X-manual.aws.gluo.cloud

## 2. Azure ##

* Create a VM: b1.ms
* Create a DNS record: X-manual.azure.gluo.cloud
* Run the script: `curl -fsSL https://raw.githubusercontent.com/gluobe/multi-cloud-workshop/master/lab02_manual_setup/setup | sh`
* Visit website: http://X-manual.azure.gluo.cloud

## 3. Google Cloud ##

* Create a VM: g1.small
* Create a DNS record: X-manual.google.gluo.cloud
* Run the script: `curl -fsSL https://raw.githubusercontent.com/gluobe/multi-cloud-workshop/master/lab02_manual_setup/setup | sh`
* Visit website: http://X-manual.google.gluo.cloud
