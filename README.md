terraform-ec2-webserver
=======================
Terraform module(s) which creates an EC2 bastion and web instance on AWS

Requirements
------------

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.65 |

Providers
---------

| Name | Version |
|------|---------|
| aws | >= 2.65 |

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

Future To Do's (nice to have's)
-------------------------------

```bash
Implement S3 backend for tfstate (In originals directory)
1. create iam user
2. Attach iam user policy with AmazonS3FullAccess & AmazonDynamoDBFullAccess to the created iam user in step 1
3. Put bucket policy against bucket
4. Put bucket versioning against bucket with status enabled
5. Create iam access key for iam user created in step 1

Authors
-------

Modules managed by [ntanenbaum](https://github.com/ntanenbaum).

