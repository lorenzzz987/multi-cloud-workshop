# Lab 00 - Prerequisites #

## 1. AWS Console login ##

Verify that you can succesfully login to AWS:

URL: https://gluo-workshop.signin.aws.amazon.com/console
USERNAME: <will be provided during workshop>
PASSWORD: <will be provided during workshop>

## 2. Google Cloud Console login ##

URL: https://console.cloud.google.com
USERNAME: <will be provided during workshop>
PASSWORD: <will be provided during workshop>

## 3. Azure login ##

URL: https://portal.azure.com
USERNAME: <will be provided during workshop>
PASSWORD: <will be provided during workshop> 

## 4. Create GitHub account ##

If you do not already have a GitHub account, create one for free:

URL: https://github.com/join

## 5. Create Docker Hub account ##

If you do not already have a Docker Hub account, create one for free:

URL: https://hub.docker.com/signup

## 6. Join Slack channel ##

Join the Slack channel through:

URL: https://join.slack.com/t/multi-cloudworkshop/shared_invite/enQtNzk0MzE1OTY3OTczLTdiOTkwZDYyYzY3ZDRjZWY2YjRjMWZmOWE2YTMwYmNiZmNiZWQzZjEzYzQ1ZWQ2YjIzMWM5ZDAzNzFlZTg4NTg

## 7. Linux VM login ##

### **On Windows** ###

1. Open Putty.
1. Under `Connection->SSH->Auth`
    1. Click `Browse`.
    1. Choose the .ppk file: `managementKey.ppk`.
1. Under `Session`
    1. Fill in `ubuntu@X.mgmt.gluo.cloud`.
    1. Click `Open`.
1. Accept the fingerprint (if needed).
1. You're now logged in as the `ubuntu` user!
1. Please verify that the prompt's hostname number reflects your own ID! For example, if your ID is `1` the prompt should say `ubuntu@management-server1:~$`. If this is not the case you're not logged in to the wrong management instance.
  
### **On Linux or MacOS** ###

1. Open your Terminal.
1. `chmod 400 lab_ManagementKey` 
    * Make sure the key file has no permissions on anyone but the owner.
1. `ssh -i managementKey ubuntu@X.mgmt.gluo.cloud`
    * Log in to the server with the private key.
1. Accept the fingerprint (if needed).
1. You're now logged in as the `ubuntu` user!
1. Please verify that the prompt's hostname number reflects your own ID! For example, if your ID is `1` the prompt should say `ubuntu@management-server1:~$`. If this is not the case you're not logged in to the wrong management instance.
