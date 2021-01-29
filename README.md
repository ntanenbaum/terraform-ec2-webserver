terraform-ec2-webserver
=======================
Terraform module(s) which creates VPC, Public|Private Subnets, Security Groups, NATs,
Internet GWs, Route Tables, Route Associations, and EC2 bastion|web instance on AWS.

Branches
--------
main -> Public Subnets for basic web server

challenge -> Public|Private Subnets, NAT for basic web server (needs work)

Requirements
------------

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| aws | >= 2.65 |

Providers
---------

| Name | Version |
|------|---------|
| aws | >= 2.65 |

Installing Terraform | Linux
----------------------------

1. Downloading Terraform 0.14.5.
```bash
$ mkdir /tmp/downloads && cd /tmp/downloads
$ sudo wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
$ sudo unzip terraform_0.14.5_linux_amd64.zip
```
2. Adding terraform to your running services.
```bash
$ sudo mv terraform /usr/local/bin/terraform
```
3. To check if Terraform v0.14.5 is installed correctly run the following command.
```bash
$ terraform -version
```
and it will show you that you have installed terraform 0.14.5

Usage
-----

```yaml
Utilizing the make command

# Lists a help menu
$ make help

# Run all terraform commands
$ make tf-all

# Cleanup
$ make tf-clean

Utilizing the bash script
# Running the script will run all terraform commands
$ ./scripts/tf_script.sh
```

Future To Do's (nice to have's)
-------------------------------

```yaml
Implement S3 backend for tfstate (In originals directory)
1. create iam user
2. Attach iam user policy with AmazonS3FullAccess & AmazonDynamoDBFullAccess
   to the created iam user in step 1
3. Put bucket policy against bucket
4. Put bucket versioning against bucket with status enabled
5. Create iam access key for iam user created in step 1
```

Authors
-------

Managed by [ntanenbaum](https://github.com/ntanenbaum).

