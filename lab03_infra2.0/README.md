# Lab 03 - Infrastructure 2.0 #

## 1. CloudFormation on AWS ##

In this lab we will use CloudFormation to deploy our EC2 instance and Route53 records to AWS.  The CloudFormation template that contains all the resources we require is shown below:

```
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html#w1ab2c21c45c15c15
# Amazon EC2 instance in a security group Creates an Amazon EC2 instance in an Amazon EC2 security group.
---
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS CloudFormation Sample Template EC2InstanceWithSecurityGroupSample:
  Create an Amazon EC2 instance running the Amazon Linux AMI. The AMI is chosen based
  on the region in which the stack is run. This example creates an EC2 security group
  for the instance to give you SSH access. **WARNING** This template creates an Amazon
  EC2 instance. You will be billed for the AWS resources used if you create a stack
  from this template.'
Parameters:
  KeyName:
    Description: Name of an existing EC2 KeyPair to enable SSH access to the instance
    Type: AWS::EC2::KeyPair::KeyName
    ConstraintDescription: must be the name of an existing EC2 KeyPair.
  InstanceType:
    Description: WebServer EC2 instance type
    Type: String
    Default: t2.micro
    AllowedValues:
    - t1.micro
    - t2.nano
    - t2.micro
    ConstraintDescription: must be a valid EC2 instance type.
  SSHLocation:
    Description: The IP address range that can be used to SSH to the EC2 instances
    Type: String
    MinLength: '9'
    MaxLength: '18'
    Default: 0.0.0.0/0
    AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.
  HostedZoneName:
    Description: The route53 HostedZoneName. For example, "gluo.cloud."  Don't forget the period at the end.
    Type: String
    Default: gluo.cloud.
  Subdomain:
    Description: The subdomain of the dns entry. This should be studentX, replace X with your number.
    Type: String
Mappings:
  AWSInstanceType2Arch:
    t1.micro:
      Arch: PV64
    t2.nano:
      Arch: HVM64
    t2.micro:
      Arch: HVM64
  AWSInstanceType2NATArch:
    t1.micro:
      Arch: NATPV64
    t2.nano:
      Arch: NATHVM64
    t2.micro:
      Arch: NATHVM64
  AWSRegionArch2AMI:
    eu-west-1:
      PV64: ami-4cdd453f
      HVM64: ami-f9dd458a
      HVMG2: ami-2955524f
Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType:
        Ref: InstanceType
      SecurityGroups:
      - Ref: InstanceSecurityGroup
      KeyName:
        Ref: KeyName
      ImageId:
        Fn::FindInMap:
        - AWSRegionArch2AMI
        - Ref: AWS::Region
        - Fn::FindInMap:
          - AWSInstanceType2Arch
          - Ref: InstanceType
          - Arch
      Tags:
        - 
          Key: "Name"
          Value: !Join ['', ["terraform-instance-aws-",!Ref 'Subdomain']]
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH access via port 22
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '22'
        ToPort: '22'
        CidrIp:
          Ref: SSHLocation
  DnsRecord:
    Type: AWS::Route53::RecordSet
    Properties:
      HostedZoneName: !Ref 'HostedZoneName'
      Comment: DNS name for my instance.
      Name: !Join ['', [!Ref 'Subdomain', ., !Ref 'HostedZoneName']]
      Type: CNAME
      TTL: '900'
      ResourceRecords:
      - !GetAtt EC2Instance.PublicIp
Outputs:
  InstanceId:
    Description: InstanceId of the newly created EC2 instance
    Value:
      Ref: EC2Instance
  AZ:
    Description: Availability Zone of the newly created EC2 instance
    Value:
      Fn::GetAtt:
      - EC2Instance
      - AvailabilityZone
  PublicDNS:
    Description: Public DNSName of the newly created EC2 instance
    Value:
      Fn::GetAtt:
      - EC2Instance
      - PublicDnsName
  PublicIP:
    Description: Public IP address of the newly created EC2 instance
    Value:
      Fn::GetAtt:
      - EC2Instance
      - PublicIp
```

Copy the content into a file name `cloudformation.yml` on your laptop.  You will need to updload this file to the AWS Console later.

Next, peform the following steps.

1. Select `Services` on the top left of the Console screen.
1. Click on `CloudFormation` (or search for it first and then click on the link)
1. Click the orange `Create Stack` on the right side of the Console screen
1. Select the `Upload a template file` option
1. Click the `Select file` button
1. Search for the `cloudformation.yml` file you create above and select it
1. Click the orange `Next` button
1. Enter the `Stack name`, this should be **studentX** (replace the X with your actual student ID)
1. In the `KeyName` dropdown select the **workshop-key-students** key
1. Enter the `Subdomain`, this should again be **studentX** (replace the X with your actual student ID)]
1. Click the orange `Next` button
1. You can ignore the red warnings, simply scroll to the bottom of the page and click the orange `Next` button
1. Scroll yet again to the bottom of the page and click the orange `Create stack` button

You should now see that your stack is being created, as soon as the created is completed.  Go the `EC2` and `Route53` section of the AWS Console to verify that your resources have actually been created.

## 2. Deployment Manager on Google Cloud ##

Not yet available

## 3. ARM Templates on Azure ##

Not yet available

## 4. Cleanup ##

### AWS ###

Go back to the `CloudFormation` section, select your own stack and click the `Delete` button, confirm by clicking the orange `Delete stack` button.  As soon as your stack has been successfully deleted visit the `EC2` and `Route53` sections again to confirm that your resources have indeed been cleaned up completely.

## Google Cloud ##

Not yet available

## Azure ##

Not yet available