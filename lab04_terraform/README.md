# Lab 04 - Terraform #

In this lab we will be using [Terraform](https://www.terraform.io/).

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

## 2. Clone repository ##

Before we can proceed we will need to clone the repository that holds the required Terraform code, to do so run the following command from the managment server:

```
git clone https://github.com/gluobe/multi-cloud-workshop
```

## 3. AWS configuration ##

Before we can deploy our infrastructure into AWS using Terraform we need to make some small changes to the Terraform code.  More specifically we need to edit the `variables.tf` file and specify our student ID.  To do so use either `vi`, `vim` or `nano`.  For example:

```
vi ~/multi-cloud-workshop/lab04_terraform/aws/variables.tf

---

> # replace the X with your student ID
> variable "studentID" {
>   default = "X"         <========= make change here
> }
>
> variable "aws_machine_type" {
>   default = "t2.micro"
> }
> 
> 
> # ---- DO NOT EDIT anything below this line -----------------------------
> 
> variable "aws_region" {
>   default = "eu-west-1"
> }
> variable "aws_ami" {
>   default = "ami-03ef731cc103c9f09"
> }
```

If you have successfully edited and saved the `variables.tf` file you can change into the directory that contains the Terraform code for AWS:

```
cd ~/multi-cloud-workshop/lab04_terraform/aws/
```

Have a look at the content of the Terraform file:

```
cat main.tf

---

provider "aws" {
}

resource "aws_instance" "ec2-instance" {
  ami             = "${var.aws_ami}"
  instance_type   = "${var.aws_machine_type}"
  key_name        = "${aws_key_pair.workshop_key.key_name}"

  security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_http.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo hostname terraform-instance-aws-student${var.studentID}",
      "echo '127.0.1.1 terraform-instance-aws-student${var.studentID}'| sudo tee -a /etc/hosts",
      "curl -fsSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker ubuntu",
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("~/.ssh/workshop_key")}"
      host          = "${self.public_ip}"
    }
  }

  tags = {
    Name = "terraform-instance-aws-student${var.studentID}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh-student${var.studentID}"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
 name        = "allow-http-students"
 description = "Allow HTTP inbound traffic"
 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "allow_outbound" {
  name        = "allow-all-outbound-student${var.studentID}"
  description = "Allow all outbound traffic"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "workshop_key" {
  key_name   = "workshop-key-student${var.studentID}"
  public_key = "${file("~/.ssh/workshop_key.pub")}"
}

resource "aws_route53_record" "gluo-cloud" {
  zone_id = "Z21MGD5XPMOZBV"
  name    = "${var.studentID}.tf.aws.gluo.cloud."
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.ec2-instance.public_dns}"]
}
```

Now we need initialize our working directory for AWS using the `terraform init` command.

The terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

```
terraform init

---

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.32.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.32"
```

Now we can run the `terraform plan` command.

The terraform plan command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.

This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state. For example, terraform plan might be run before committing a change to version control, to create confidence that it will behave as expected.

```
terraform plan

---

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.ec2-instance will be created
  + resource "aws_instance" "ec2-instance" {
      + ami                          = "ami-03ef731cc103c9f09"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "workshop-key-studentX"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = [
          + "allow-all-outbound-studentX",
          + "allow-ssh-studentX",
        ]
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "terraform-instance-aws-studentX"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_key_pair.workshop_key will be created
  + resource "aws_key_pair" "workshop_key" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "workshop-key-studentX"
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiPMnEZoPD3ZtnA2V3Zlpo+z1BdwDnztD38WqYeFqhFQyNIABuxsKc+OiZfxm3R4g+VyNWqRT4poPex/JIHq9B8ACIAZdfGWe05xHXtas4XqshXxweocK8Y2lsd2wehWsJ4gH9vVyg/JvxXAxfNEEVxzodD9MFJJNjtTsx6vH+6PhsiG3xmql7fUDEIp/tLFJ7nzKKFbV4hPLaCS5eNSxyyjkL52VvIrh5SxhebAJMaVVvjhJPrH3pELUX2hMcKOaocqJ02/WnLbki6+p+zCaL6xIMMwfajXbQmfb6FoF1X72V08/Ll/3lO7EGZxvq75rB+v3y9C9QrtYHXM3++jpV ubuntu@studentX-management"
    }

  # aws_route53_record.gluo-cloud will be created
  + resource "aws_route53_record" "gluo-cloud" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "x.tf.aws.gluo.cloud"
      + records         = (known after apply)
      + ttl             = 60
      + type            = "CNAME"
      + zone_id         = "Z21MGD5XPMOZBV"
    }

  # aws_security_group.allow_outbound will be created
  + resource "aws_security_group" "allow_outbound" {
      + arn                    = (known after apply)
      + description            = "Allow all outbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow-all-outbound-studentX"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Allow SSH inbound traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "allow-ssh-studentX"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Pay special attention to one of the last lines, it reads:

```
Plan: 5 to add, 0 to change, 0 to destroy.
```

This gives you a good overview of what Terraform wil do (add, change and/or destroy).  If you are happy with what Terraform is going to to do you can run the `terraform apply` command.

The terraform apply command is used to apply the changes required to reach the desired state of the configuration, or the pre-determined set of actions generated by a terraform plan execution plan.

> NOTE: Terraform will prompt you if it should proceed, type `yes` and hit ENTER

```
terraform apply

---

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.ec2-instance will be created
  + resource "aws_instance" "ec2-instance" {
      + ami                          = "ami-03ef731cc103c9f09"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "workshop-key-studentX"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = [
          + "allow-all-outbound-studentX",
          + "allow-ssh-studentX",
        ]
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "terraform-instance-aws-studentX"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_key_pair.workshop_key will be created
  + resource "aws_key_pair" "workshop_key" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "workshop-key-studentX"
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiPMnEZoPD3ZtnA2V3Zlpo+z1BdwDnztD38WqYeFqhFQyNIABuxsKc+OiZfxm3R4g+VyNWqRT4poPex/JIHq9B8ACIAZdfGWe05xHXtas4XqshXxweocK8Y2lsd2wehWsJ4gH9vVyg/JvxXAxfNEEVxzodD9MFJJNjtTsx6vH+6PhsiG3xmql7fUDEIp/tLFJ7nzKKFbV4hPLaCS5eNSxyyjkL52VvIrh5SxhebAJMaVVvjhJPrH3pELUX2hMcKOaocqJ02/WnLbki6+p+zCaL6xIMMwfajXbQmfb6FoF1X72V08/Ll/3lO7EGZxvq75rB+v3y9C9QrtYHXM3++jpV ubuntu@studentX-management"
    }

  # aws_route53_record.gluo-cloud will be created
  + resource "aws_route53_record" "gluo-cloud" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "x.tf.aws.gluo.cloud"
      + records         = (known after apply)
      + ttl             = 60
      + type            = "CNAME"
      + zone_id         = "Z21MGD5XPMOZBV"
    }

  # aws_security_group.allow_outbound will be created
  + resource "aws_security_group" "allow_outbound" {
      + arn                    = (known after apply)
      + description            = "Allow all outbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow-all-outbound-studentX"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Allow SSH inbound traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "allow-ssh-studentX"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.workshop_key: Creating...
aws_security_group.allow_ssh: Creating...
aws_security_group.allow_outbound: Creating...
aws_key_pair.workshop_key: Creation complete after 0s [id=workshop-key-studentX]
aws_security_group.allow_ssh: Creation complete after 1s [id=sg-05b018c85966c2d97]
aws_security_group.allow_outbound: Creation complete after 1s [id=sg-0983e4aea802e8633]
aws_instance.ec2-instance: Creating...
aws_instance.ec2-instance: Still creating... [10s elapsed]
aws_instance.ec2-instance: Provisioning with 'remote-exec'...
aws_instance.ec2-instance (remote-exec): Connecting to remote host via SSH...
aws_instance.ec2-instance (remote-exec):   Host: 52.31.170.106
aws_instance.ec2-instance (remote-exec):   User: ubuntu
aws_instance.ec2-instance (remote-exec):   Password: false
aws_instance.ec2-instance (remote-exec):   Private key: true
aws_instance.ec2-instance (remote-exec):   Certificate: false
aws_instance.ec2-instance (remote-exec):   SSH Agent: false
aws_instance.ec2-instance (remote-exec):   Checking Host Key: false
aws_instance.ec2-instance: Still creating... [20s elapsed]
aws_instance.ec2-instance: Still creating... [30s elapsed]
aws_instance.ec2-instance (remote-exec): Connecting to remote host via SSH...
aws_instance.ec2-instance (remote-exec):   Host: 52.31.170.106
aws_instance.ec2-instance (remote-exec):   User: ubuntu
aws_instance.ec2-instance (remote-exec):   Password: false
aws_instance.ec2-instance (remote-exec):   Private key: true
aws_instance.ec2-instance (remote-exec):   Certificate: false
aws_instance.ec2-instance (remote-exec):   SSH Agent: false
aws_instance.ec2-instance (remote-exec):   Checking Host Key: false
aws_instance.ec2-instance (remote-exec): Connected!
aws_instance.ec2-instance (remote-exec): sudo: unable to resolve host terraform-instance-aws-studentX
aws_instance.ec2-instance (remote-exec): 127.0.1.1 terraform-instance-aws-studentX
aws_instance.ec2-instance (remote-exec): # Executing docker install script, commit: f45d7c11389849ff46a6b4d94e0dd1ffebca32c1
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c apt-get update -qq >/dev/null
aws_instance.ec2-instance: Still creating... [40s elapsed]
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq - >/dev/null
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker.list
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c apt-get update -qq >/dev/null
aws_instance.ec2-instance (remote-exec): + [ -n  ]
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c apt-get install -y -qq --no-install-recommends docker-ce >/dev/null
aws_instance.ec2-instance: Still creating... [50s elapsed]
aws_instance.ec2-instance: Still creating... [1m0s elapsed]
aws_instance.ec2-instance (remote-exec): + sudo -E sh -c docker version
aws_instance.ec2-instance (remote-exec): Client: Docker Engine - Community
aws_instance.ec2-instance (remote-exec):  Version:           19.03.3
aws_instance.ec2-instance (remote-exec):  API version:       1.40
aws_instance.ec2-instance (remote-exec):  Go version:        go1.12.10
aws_instance.ec2-instance (remote-exec):  Git commit:        a872fc2
aws_instance.ec2-instance (remote-exec):  Built:             Tue Oct  8 00:59:54 2019
aws_instance.ec2-instance (remote-exec):  OS/Arch:           linux/amd64
aws_instance.ec2-instance (remote-exec):  Experimental:      false

aws_instance.ec2-instance (remote-exec): Server: Docker Engine - Community
aws_instance.ec2-instance (remote-exec):  Engine:
aws_instance.ec2-instance (remote-exec):   Version:          19.03.3
aws_instance.ec2-instance (remote-exec):   API version:      1.40 (minimum version 1.12)
aws_instance.ec2-instance (remote-exec):   Go version:       go1.12.10
aws_instance.ec2-instance (remote-exec):   Git commit:       a872fc2
aws_instance.ec2-instance (remote-exec):   Built:            Tue Oct  8 00:58:28 2019
aws_instance.ec2-instance (remote-exec):   OS/Arch:          linux/amd64
aws_instance.ec2-instance (remote-exec):   Experimental:     false
aws_instance.ec2-instance (remote-exec):  containerd:
aws_instance.ec2-instance (remote-exec):   Version:          1.2.10
aws_instance.ec2-instance (remote-exec):   GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
aws_instance.ec2-instance (remote-exec):  runc:
aws_instance.ec2-instance (remote-exec):   Version:          1.0.0-rc8+dev
aws_instance.ec2-instance (remote-exec):   GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
aws_instance.ec2-instance (remote-exec):  docker-init:
aws_instance.ec2-instance (remote-exec):   Version:          0.18.0
aws_instance.ec2-instance (remote-exec):   GitCommit:        fec3683
aws_instance.ec2-instance (remote-exec): If you would like to use Docker as a non-root user, you should now consider
aws_instance.ec2-instance (remote-exec): adding your user to the "docker" group with something like:

aws_instance.ec2-instance (remote-exec):   sudo usermod -aG docker ubuntu

aws_instance.ec2-instance (remote-exec): Remember that you will have to log out and back in for this to take effect!

aws_instance.ec2-instance (remote-exec): WARNING: Adding a user to the "docker" group will grant the ability to run
aws_instance.ec2-instance (remote-exec):          containers which can be used to obtain root privileges on the
aws_instance.ec2-instance (remote-exec):          docker host.
aws_instance.ec2-instance (remote-exec):          Refer to https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface
aws_instance.ec2-instance (remote-exec):          for more information.
aws_instance.ec2-instance: Creation complete after 1m2s [id=i-0e3aaa0b73ca16a03]
aws_route53_record.gluo-cloud: Creating...
aws_route53_record.gluo-cloud: Still creating... [10s elapsed]
aws_route53_record.gluo-cloud: Still creating... [20s elapsed]
aws_route53_record.gluo-cloud: Still creating... [30s elapsed]
aws_route53_record.gluo-cloud: Creation complete after 32s [id=Z21MGD5XPMOZBV_x.tf.aws.gluo.cloud._CNAME]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

Now go to the AWS console and check that your EC2 instance and Route53 has been created succesfully!

## 4. Google Cloud configuration ##

Before we can deploy our infrastructure into Google Cloud using Terraform we need to make some small changes to the Terraform code.  More specifically we need to edit the `variables.tf` file and specify our student ID.  To do so use either `vi`, `vim` or `nano`.  For example:

```
vi ~/multi-cloud-workshop/lab04_terraform/google/variables.tf

---

> # replace the X with your student ID
> variable "studentID" {
>   default = "X"         <========= make change here
> }
> 
> variable "gcp_machine_type" {
>   default = "g1-small"
> }
> 
> # ---- DO NOT EDIT anything below this line -----------------------------
> 
> variable "gcp_project" {
>   default = "gluo-sandbox"
> }
> variable "gcp_region" {
>   default = "europe-westq"
> }
> variable "gcp_zone" {
>   default = "europe-west1-b"
> }
```

If you have successfully edited and saved the `variables.tf` file you can change into the directory that contains the Terraform code for Google Cloud:

```
cd ~/multi-cloud-workshop/lab04_terraform/google/
```

Have a look at the content of the Terraform file:

```
cat main.tf

---

provider "google" {
  project = "${var.gcp_project}"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_zone}"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-google-student${var.studentID}"
  machine_type = "${var.gcp_machine_type}"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/workshop_key.pub")}"
        startup-script = <<SCRIPT
        sudo hostname terraform-instance-google-student${var.studentID}
        echo '127.0.1.1 terraform-instance-google-student${var.studentID}' | sudo tee -a /etc/hosts
        curl -fsSL https://get.docker.com/ | sh
        sudo usermod -aG docker ubuntu
        SCRIPT
    }

  network_interface {
    network       = "default"
    access_config {
    }
  }
}

resource "google_dns_record_set" "a" {
  name = "${var.studentID}.google.gluo.cloud."
  managed_zone = "google-gluo-cloud"
  type = "A"
  ttl  = 60

  rrdatas = ["${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"]
}

/* Ports openzetten
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network-student${var.studentID}"
  auto_create_subnetworks = "true"
}
*/

output "ip" {
 value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}
```

Now we need initialize our working directory for Google Cloud using the `terraform init` command again.

```
terraform init
```

Now we can run the `terraform plan` command again to see what Terraform is going to do.

```
terraform plan
```

If you are happy with what Terraform is going to to do you can run the `terraform apply` command again.

```
terraform apply
```

Now go to the Google Cloud console and check that your instance and DNS record has been created succesfully!

## 5. Azure configuration ##

Before we can deploy our infrastructure into Azure using Terraform we need to make some small changes to the Terraform code.  More specifically we need to edit the `variables.tf` file and specify our student ID.  To do so use either `vi`, `vim` or `nano`.  For example:

```
vi ~/multi-cloud-workshop/lab04_terraform/azure/variables.tf

---

> # replace the X with your student ID
> variable "studentID" {
>   default = "X"
> }
> 
> variable "azure_machine_type" {
>   default = "Standard_B1ms"
> }
> 
> # ---- DO NOT EDIT anything below this line -----------------------------
> 
> variable "location" {
>   default = "westeurope"
> }
```

If you have successfully edited and saved the `variables.tf` file you can change into the directory that contains the Terraform code for Azure:

```
cd ~/multi-cloud-workshop/lab04_terraform/azure/
```

Have a look at the content of the Terraform file:

```
cat main.tf

---

provider "azurerm" {
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "terraform-multicloud-ip-student${var.studentID}"
    location                     = "${var.location}"
    resource_group_name          = "multi-cloud-workshop-pxl-${var.studentID}"
    allocation_method            = "Static"
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "terraform-multicloud-secgroup-student${var.studentID}"
    location            = "${var.location}"
    resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

		security_rule {
        name                       = "HTTP"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                = "terraform-multicloud-nic-student${var.studentID}"
    location            = "${var.location}"
    resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "terraform-multicloud-nicCfg-student${var.studentID}"
        subnet_id                     = "/subscriptions/138059db-9be5-43ba-979f-67dcc9ee5e3d/resourceGroups/multicloud-workshop/providers/Microsoft.Network/virtualNetworks/multicloud-workshop-vnet/subnets/default"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "terraform-instance-azure-student${var.studentID}"
    location              = "${var.location}"
    resource_group_name   = "multi-cloud-workshop-pxl-${var.studentID}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "${var.azure_machine_type}"

    storage_os_disk {
        name              = "myOsDisk-student${var.studentID}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "terraform-instance-azure-student${var.studentID}"
        admin_username = "ubuntu"
        custom_data    = file("cloud-config.txt")
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/ubuntu/.ssh/authorized_keys"
            key_data = file("~/.ssh/workshop_key.pub")
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "https://multicloudworkshopdiag.blob.core.windows.net/"
    }
}

data "azurerm_public_ip" "test" {
  name                = "${azurerm_public_ip.myterraformpublicip.name}"
  resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"
}

resource "azurerm_dns_a_record" "myterraformdns" {
  name                = "${var.studentID}"
  zone_name           = "azure.gluo.cloud"
  resource_group_name = "multi-cloud-workshop"
  ttl                 = 60
  records             = ["${data.azurerm_public_ip.test.ip_address}"]
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.test.ip_address}"
}
```

Now we need initialize our working directory for Azure using the `terraform init` command again.

```
terraform init
```

Now we can run the `terraform plan` command again to see what Terraform is going to do.

```
terraform plan
```

If you are happy with what Terraform is going to to do you can run the `terraform apply` command again.

```
terraform apply
```

Now go to the Azure portal and check that your instance and DNS record has been created succesfully!

## 6. Cleanup ##

You should have noticed how easy it is to deploy similar infrastructure to different clouds using the same tools/language.  It is equally easy to clean up (destroy) infrastructure resources you created with Terraform.  With the following commands you will remove all the resources you previously created.

Make sure that everything is deleted correctly, if you run into any issues let one of the instructors know.

Delete all resources on AWS:

```
cd ~/multi-cloud-workshop/lab04_terraform/aws/

terraform destroy
``` 

Delete all resources on Google Cloud:

```
cd ~/multi-cloud-workshop/lab04_terraform/google/

terraform destroy
``` 

Delete all resources on Azure:

```
cd ~/multi-cloud-workshop/lab04_terraform/azure/

terraform destroy
```