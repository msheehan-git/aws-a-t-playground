[Return to main page](../README.md)

# Create Security Group


The default network security for EC2 nodes is full access inbound and out. Here we are creating a security group that will restrict access during the provisioning process. 

1. Make a subdirectory called secure under the main directory and create the variables.tf. We'll need to reference the VPC from vpc module.

./secure/variables.tf
```diff
variable "playground_vpc_id" {
  type        = string
  description = "The VPC ID created in vpc module"
}

```

2. Create a file called limited-access-grp.tf that will limit access to SSH (port 22) and your home IP address. There are two types of flows. Inbound are "ingress" and outbound are "egress". We'll restrict ingress and leave egress fully open.

In the example below is private IP 192.168.2.25. You need to add the IP of your modem. Unsure what that is? Several sites will show you. Here's one [https://whatismyipaddress.com](https://whatismyipaddress.com).

./secure/limited-access-grp.tf
```diff
resource "aws_security_group" "limited_access" {
  name = "limited_access"
  
  vpc_id = var.playground_vpc_id
  
  ingress {
    
    cidr_blocks = [
      "192.168.2.25/32"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  } 
   

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

```
 Note that the CIDR being used is /32.  This is a single address and limits access to only the IP listed. You can add additional address blocks as coma separated or expand the CIDR.

 Example:
 ```diff

  cidr_blocks = [
      "192.168.2.25/32",
      "18.206.107.24/29"
    ]
```

2.  The security group will be used by other modules so we need to capture in output.tf. Create the output.tf in secure subdirectory. 

./secure/output.tf
```diff
output "aws_secure_group_id" {
  value = aws_security_group.limited_access.id
}

```

3. Edit the main.tf. Add the security module with a reference to the VPC module.

partial section of main.tf
```diff
module "secure" {
  source            = "./secure"
  playground_vpc_id = module.vpc.playground_vpc_id
}

```
4. Initialize terraform and add the secure module

```diff
terraform init

```
Initializing the backend...
Initializing modules...
- secure in secure

5. Now terraform plan and apply to create the security group. 


```diff
terraform plan
```

```diff
terraform apply
```

module.secure.aws_security_group.limited_access: Creating...

6. Next up: [Provision EC2 Nodes](./Provision-EC2-Nodes.md)