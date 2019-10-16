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
 name        = "allow-http-student${var.studentID}
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

