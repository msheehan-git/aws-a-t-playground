[Return to main page](../README.md)

# Provision the AWS Network


Now we will provision the network. The network consists of the [subnet](#subnet), [gateway](#gateway), [route-table](#route-table) and [route-table association](#route-table-association). We will build the network after creating resources.

1. To prepare this module we need to declare the VPC resource we created earlier. Create a subdirectory called network under the main directory. Edit a file called  variables.tf. Add the variable "vpc_playground_id" which matches the ./vpc/output.tf 


./network/variables.tf
```diff
variable "vpc_playground_id" {
  type        = string
  description = "The VPC ID created in vpc module"
}

```

2. Copy the providers.tf from main directory. 


# subnet

1. Add a file called aws_subnet.tf

./network/aws_subnet.tf
```diff
resource "aws_subnet" "private_playground_subnet_us_east_1a" {
  vpc_id                  = var.playground_vpc_id
  availability_zone       = "us-east-1a"
  cidr_block              = "172.31.32.0/24"
  map_public_ip_on_launch = "true"
}

```

Here we are creating the aws_subnet resource with a TF object name of private_subnet_us_east_1a. For cidr_block we are allocating a subset of the IPs available to the VPC.  Finally we are referencing the variable var.playground_vpc_id for the vpc_id of to instruct where to provision the subnet. The map_public_ip_on_launch = "true" will allocate a dynamic public IP to resources running in this subnet.



2. We also need to make the subnet resource available to other modules. As we did we the vpc. create an output.tf file in the network directory.

network/output.tf
```diff
output "private_playground_subnet_us_east_1a_id" {
  value = aws_subnet.private_playground_subnet_us_east_1a.id
}
```


3. Next we'll create additional resources for the network. 


# Gateway

1. Create the aws-gateway.tf in the network directory. The configuration should reference the vpc_id that was created in the vpc module. 


./network/aws-gateway.tf
```diff
resource "aws_internet_gateway" "playground_gw" {
  vpc_id = var.playground_vpc_id
}

```


# Route-Table

1. Create the aws-route-table.tf in the network directory. The configuration should reference the vpc_id that was created in the vpc module. 

./network/aws-route-table.tf

```diff
resource "aws_route_table" "allow_all_inbound" {
  vpc_id = var.playground_vpc_id

  route {
    cidr_block         = "0.0.0.0/0"
    gateway_id         = aws_internet_gateway.playground_gw.id
  }

  route {
    ipv6_cidr_block    = "::/0"
    gateway_id         = aws_internet_gateway.playground_gw.id
  }

  tags = {
    Name = "allow-all-inbound"
  }
}

```


# Route-Table Association

1. Create the aws-route-table-association.tf in the network directory. The configuration should reference the vpc_id that was created in the vpc module and the aws_internet_gateway that's defined above. 

./network/aws-route-table-association.tf
```diff
resource "aws_route_table" "allow_all_inbound" {
  vpc_id = var.playground_vpc_id

  route {
    cidr_block         = "0.0.0.0/0"
    gateway_id         = aws_internet_gateway.playground_gw.id
  }

  route {
    ipv6_cidr_block    = "::/0"
    gateway_id         = aws_internet_gateway.playground_gw.id
  }

  tags = {
    Name = "allow-all-inbound"
  }
}

```


# Building the network

We've created the network module. We've defined resources within the network that rely on each other that haven't been created yet.  Terraform will be able to associate these during the apply process. 

2. Now edit the main.tf and add the network module

main.tf
```diff
terraform {
  backend "s3" {
    bucket = "tfstate-aws-bucket-23423f"
    key    = "aws-test/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source   = "./vpc"
}

module "network" {
  source            = "./network"
  playground_vpc_id = module.vpc.playground_vpc_id
}

```    

In the network module, define "playground_vpc_id". The path is "module.[directory-of-module].[value-in-output.tf]"


2. Initialize the network module

```diff
terraform init

```
Initializing the backend...
Initializing modules...
- network in network


3.  Plan and Apply - Here take note of terraform creating resources that reference other resources that have yet to be created.

Example:
  "# module.network.aws_route_table_association.allow_all_inbound will be created"
  + resource "aws_route_table_association" "allow_all_inbound" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

We haven't created the subnet, route_table that the aws_route_table_association needs. Terraform will resolve this during the create process of apply. 


4. Now that the network is ready, we'll prepare to provision ec2-nodes. We'll start by creating a security group for the nodes. [Create Security Group](./Create-Security-Group.md)
