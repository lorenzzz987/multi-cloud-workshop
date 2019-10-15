# Lab 01 - Our application #

The goal of this lab is to run our application on our managment server.  To make our lives a little bit easier we will be using Docker for this.  For people not familiar with Docker: Docker is a tool designed to make it easier to create, deploy, and run applications by using containers. Containers allow a developer to package up an application with all of the parts it needs, such as libraries and other dependencies, and ship it all out as one package.

## 0. Fork the application repository ##

Before doing anything else, open your browser en visit the following GitHub page:

https://github.com/gluobe/multi-cloud-app

On the top right you should see a `Fork` button, click this button and fork the repository into your own GitHub account.

NOTE: it is important that from now on you only use your own fork

## 1. Install Docker ##

Installing Docker is easy, simply run the command below:

```
curl -fsSL https://get.docker.com/ | sh
```

The installation should take 1 or 2 minutes, and you should see output similar to the output below:

```
# Executing docker install script, commit: f45d7c11389849ff46a6b4d94e0dd1ffebca32c1
+ sudo -E sh -c apt-get update -qq >/dev/null
+ sudo -E sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
+ sudo -E sh -c curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add -qq - >/dev/null
Warning: apt-key output should not be parsed (stdout is not a terminal)
+ sudo -E sh -c echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
+ sudo -E sh -c apt-get update -qq >/dev/null
+ [ -n  ]
+ sudo -E sh -c apt-get install -y -qq --no-install-recommends docker-ce >/dev/null
+ sudo -E sh -c docker version
Client: Docker Engine - Community
 Version:           19.03.3
 API version:       1.40
 Go version:        go1.12.10
 Git commit:        a872fc2f86
 Built:             Tue Oct  8 00:59:36 2019
 OS/Arch:           linux/amd64
 Experimental:      false
Server: Docker Engine - Community
 Engine:
  Version:          19.03.3
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.10
  Git commit:       a872fc2f86
  Built:            Tue Oct  8 00:58:08 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.10
  GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
 runc:
  Version:          1.0.0-rc8+dev
  GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
If you would like to use Docker as a non-root user, you should now consider
adding your user to the "docker" group with something like:
  sudo usermod -aG docker ubuntu
Remember that you will have to log out and back in for this to take effect!
WARNING: Adding a user to the "docker" group will grant the ability to run
         containers which can be used to obtain root privileges on the
         docker host.
         Refer to https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface
         for more information.
```

Once the installation is complete run the following command to add your current user to the Docker group:

```
sudo usermod -aG docker ubuntu
```

To make sure everyting is working fine run the command below:

```
sudo docker version
```

You will see output like:

```
Client: Docker Engine - Community
 Version:           19.03.3
 API version:       1.40
 Go version:        go1.12.10
 Git commit:        a872fc2f86
 Built:             Tue Oct  8 00:59:36 2019
 OS/Arch:           linux/amd64
 Experimental:      false
Server: Docker Engine - Community
 Engine:
  Version:          19.03.3
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.10
  Git commit:       a872fc2f86
  Built:            Tue Oct  8 00:58:08 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.10
  GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
 runc:
  Version:          1.0.0-rc8+dev
  GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

NOTE: if you get any kind of error do NOT proceed, just let one of the instructors know!

## 2. Clone repository ##

Download the application code onto your management server by cloning the GitHub repository:

```
git clone https://github.org/YOURGITHUBACCOUNTNAME/multi-cloud-app
```

## 3. Dockerfile ##

We will be using a Dockerfile to create a Docker image, the Dockerfile that we will be using is extremely simple:

```
FROM php:apache

MAINTAINER steven@gluo.be

COPY . /var/www/html/
```

The Dockerfile will do the following:

* start from the `php:apache` base image (this images had Apache & PHP installed and configured)
* set a label for the maintainer (optional)
* it will copy the code into the `/var/www/html/` directory of the image

## 4. Build the Docker image ##

Change into the correct directory:

```
cd multi-cloud-app
```

Building the Docker image is as easy as running the command below, make sure to replace `YOURDOCKERHUBACCOUNTNAME` with your actual Docker Hub account name:

```
docker image build -t YOURDOCKERHUBACCOUNTNAME/multi-cloud-app:v1 .
```

Your output should look like:

```
Sending build context to Docker daemon  285.7kB
Step 1/3 : FROM php:apache
apache: Pulling from library/php
b8f262c62ec6: Pull complete
a98660e7def6: Pull complete
4d75689ceb37: Pull complete
639eb0368afa: Pull complete
99e337926e9c: Pull complete
431d44b3ce98: Pull complete
beb665ea0e0e: Pull complete
1914f5ed0362: Pull complete
3bb658c14677: Pull complete
6a4699b1063e: Pull complete
d23f6accef3d: Pull complete
3814846efc9c: Pull complete
e14c865e4394: Pull complete
2133ee9f21fd: Pull complete
Digest: sha256:5bac688433c272e2cc2674dc103f68751657d1b17cf93c64d25753da84235cae
Status: Downloaded newer image for php:apache
 ---> 8648812a79f5
Step 2/3 : MAINTAINER steven@gluo.be
 ---> Running in f1a9851978e3
Removing intermediate container f1a9851978e3
 ---> 12b892d39e7d
Step 3/3 : COPY . /var/www/html/
 ---> 5c10862bca3d
Successfully built 5c10862bca3d
Successfully tagged trescst/multi-cloud-app:v1
```

NOTE: the trailing dot ('.') of the command is very important, do not omit it when copy/pasting

You will now have 2 docker images on your system:

```
docker image ls

---

REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
trescst/multi-cloud-app   v1                  5c10862bca3d        50 seconds ago      415MB
php                       apache              8648812a79f5        9 days ago          415MB
```

## 5. Test your Docker image ##

To start a container from the Docker images you created above, run the following command (make sure to replace `YOURDOCKERHUBACCOUNTNAME` with your actual Docker Hub account name):

```
docker container run -d -p 80:80 YOURDOCKERHUBACCOUNTNAME/multi-cloud-app:v1
```

Open your browser again and visit http://X.mgmt.gluo.cloud to see if your application is running.  If you do not see the multi-cloud-app website let one of the instructors know!

## 6. Push the image to the Docker Hub ##

Next we will push our Docker image to the Docker Hub, before we can do this we will need to log into the Docker Hub, for that use the command below:

```
docker login

---

Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: YOURDOCKERHUBACCOUNTNAME
Password:
WARNING! Your password will be stored unencrypted in /home/ubuntu/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Now you are ready to push your Docker image to the Docker Hub, to do so use the command below:

```
docker image push YOURDOCKERHUBACCOUNTNAME/multi-cloud-app:v1

---

The push refers to repository [docker.io/trescst/multi-cloud-app]
24a8e281a62f: Pushed
35b4ddbd5384: Mounted from library/php
024ea5815739: Mounted from library/php
a83d0f4e6d8f: Mounted from library/php
0e86bbba7641: Mounted from library/php
357e0210f2fa: Mounted from library/php
efff16148d4f: Mounted from library/php
9582edbd2dbd: Mounted from library/php
e0269f37dcfa: Mounted from library/php
3e6f95434588: Mounted from library/php
c08a9d858420: Mounted from library/php
1a53f90adf8d: Mounted from library/php
11f457f4618a: Mounted from library/php
7e59cbad3af2: Mounted from library/php
2db44bce66cd: Mounted from library/php
v1: digest: sha256:95c53aad583feac2706d2beafa65eccd233b5a5b29dd36e65185cfe89880da95 size: 3452
```

## 7. Test an image from you colleagues ##

Post the `docker container run` command you used to Slack, for example: `docker container run -d -p 80:80 YOURDOCKERHUBACCOUNTNAME/multi-cloud-app:v1`

Now stop and remove you own container:

```
docker container rm -f $(docker container ls -ql)
```

Now run one of the `docker container run` commands that one of colleagues posted to Slack, visit http://X.mgmt.gluo.cloud again to see that also your colleagues image works without any issues on your server.

This is a good example of how easy Docker makes it to move application from one server to another (this is exactly why we will be using Docker in the next labs).
