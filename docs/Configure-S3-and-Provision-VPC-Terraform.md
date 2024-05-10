[Return to main page](../README.md)

# Configure AWS using Terraform


This is where the fun begins.  We have our AWS Account and CLI. We've installed terraform. Now we will be using terraform to provision resources in AWS.  Reminder - this is Infrastructure as Code and with coding there are many ways to get similar results. In this release we'll be focusing on terraform modules and sharing resources between them.  Terraform also supports templates which enhances the modules by writing code once as a template and using the same in multiple modules. This concept may be added in a future release of the playground. 

Also I would recommend using Visual Studio Code (VSC) with the terraform extension. This will making coding your  infrastructure easier.  [https://code.visualstudio.com](ttps://code.visualstudio.co)


#  Creating the main.tf and using the S3 backend. 

1. Using VSC or a text editor, create main.tf.

Set the bucket name to match what you created in  [Configure AWS Services](./Configure-AWS-Services.md). Add  key and file name. Here we are setting "aws-test" as a prefix to the terraform.tfstate file. This is not required but becomes helpful when you have multiple state files in a single bucket. Also add the region where your bucket was created.

The last section is the "provider" where we instruct terraform what provider to use to provision the resources. Details of this provider can be found in the terraform registry. [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

main.tf
```diff

terraform {
  backend "s3" {
    bucket = "tfstate-aws-bucket-23423f"
    key    = "aws-test/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

```
2. Create providers.tf and define the AWS Provider.

./providers.tf
```diff
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
```

Note: We'll only be using the AWS provider for this release. Future additional providers will be added to providers.tf. 

3. Next we'll initialize terraform

```diff
terraform init

```
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

# Provision the VCP

1. Create a subdirectory called vpc in the same directory where you created main.tf.


2. cd into vpc and create a file called aws-vpc.tf

./vpc/aws-vpc.tf

```diff
resource "aws_vpc" "vpc_playground" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = "vpc_playground"
  }
}

```

The CIDR block of 172.31.0.0/16 is one of recommend ranges from AWS. See [https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html) for more details.  We'll divide this block later when provisioning our subnet. 


Some notes on the above that wil carry forward in this project. Here we are define a resource block for aws_vpn with a terraform name of "vpc_playground". Terraform resource names should use an underscore as the separator. A hyphen is accepted by terraform but avoid for best practice. Also, here the terraform resource name marches the tags Name of the VPC in AWS. This is not required. An acceptable tag Name could be Name = "vpc-playground" and would not conflict with the terraform resource name. 

3. Copy the providers.tf from main directory. 


4. Go back to main.tf dir and add the vpc module to main.tf

main.tf

```diff
module "vpc" {
  source   = "./vpc"
}

```


5. Next we'll intentionally get an error to highlight the need to run "terraform init" whenever we add new modules.  Run terraform plan

```diff
terraform plan

```
Error: Module not installed
│ 
│   on main.tf line 16:
│   16: module "vpc" {
│ 
│ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.


6. Run terraform init to add the vpc module

```diff
terraform init

```

Initializing the backend...
Initializing modules...
- vpc in vpc


7. terraform plan vs terraform apply - Brief overview of terraform plan and apply parameters. The "plan" will read your configuration and note any pending changes. Always run a "plan" before "apply" to ensure the outcome will be what you expect. Additionally, if you only want to check syntax etc, use "terraform validate"


8. Now lets validate, plan and apply our configuration to provision the VPC. 

```diff
terraform validate

```
Success! The configuration is valid.

```diff
terraform plan

```

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  "# module.vpc.aws_vpc.vpc_playground will be created"
  + resource "aws_vpc" "vpc_playground" {
      + arn                                  = (known after apply)
      + cidr_block                           = "172.31.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "vpc_playground"
        }
      + tags_all                             = {
          + "Name" = "vpc_playground"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

```diff
terraform apply

```

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

Note: you can avoid the apply prompt by adding flag -auto-approve  (example - "terraform apply -auto-approve ") which you would use in a CI/CD pipeline. Here we are keeping the prompt as another confirmation. 


9. Check the date on the terraform.tfstate file. Remember the S3 bucket we added in main.tf? Now that terraform has created the VPC. the state file has been updated. We can see the state file has changed using aws CLI

```diff
 aws s3 ls tfstate-aws-bucket-23423f/aws-test/
```

20**-01-01 13:20:47      27988 terraform.tfstate


10. We've created the VPC in the vpc module. Now we need to make this resource available to other modules. This is accomplished using output.  Edit a file called output.tf in the vpc directory and add the following code.

vpc/output.tf

```diff
output "vpc_playground_id" {
  value = aws_vpc.vpc_playground.id
}
```

Here the vpc_playground will be the reference object that other modules call. The value = aws_vpc.vpc_playground.id is comprised of resource object "aws_vpc"  and name "vpc_playground" we used to create the VPC and the ID element number in AWS. 


11. VPC has been created. Let's [Provision the Network](./Provision-AWS-Network.md)
