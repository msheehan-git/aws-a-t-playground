[Return to main page](../README.md)

# Terraform Import with Ansible Create

In the last section we created a new EC2 instance by copying an existing terraform file and changing some of the values. We also used terraform to recreate an instance that had been deleted without terraform's awareness. In this demonstration we'll be importing an EC2 instance that had been created using ansible and enable terraform tp manage it. 

Note: As stated earlier, the design of this playground has terraform provisioning and maintaining infrastructure and ansible maintaining the services and configuration of the infrastructure. However, since ansible can create EC2 instances this is a good opportunity to display a method to do so.

1. Create af file in your play-books directory called "aws-create-ans-client-3.yml"

./play-books/aws-create-ans-client-3.yml
```diff
---
  - name: Provision node
    hosts: localhost
    gather_facts: false
    tasks
    - name: Provision node
      ec2_instance:
        name: "ans-client-3"
        key_name: 
        vpc_subnet_id: 
        instance_type: 
        security_group: 
        network:
          assign_public_ip: true
        image_id: 
        
```

We could then use multiple means to gather the information and fill in the blanks. However, we can leverage an existing node and extract the details using the ec2_instance_info module. 


./play-books/aws-create-ans-client-3.yml
```diff
---
- name: Create an EC2 Node using Ansible
  hosts: localhost
  gather_facts: false
  tasks:
    - name: get ec2 instance info
      ec2_instance_info:
        filters:
          tag:Name: ["ans-client-1"]
      register: ec2_info


    - name: Provision node
      ec2_instance:
        name: "ans-client-3"
        key_name: "{{ ec2_info.instances[0].key_name }}"
        vpc_subnet_id: "{{ ec2_info.instances[0].subnet_id }}"
        instance_type: "{{ ec2_info.instances[0].instance_type }}"
        security_group: "limited_access"
        image_id: "{{ ec2_info.instances[0].image_id }}"
        tags:
          webserver: "true"

 ```

Here are using ans-client-1 as our source node,registering the info to variable "ec2_info". Then we use the ec2_instance module to provision the resource.  The  ec2_instance_info module had a filter for a single node so we do not have to loop through as we did previously.  Instead we will reference element ID 0 and extract the fields we want to build a new node. The security_group and tags fields are lists. We are specifying the value we want. 


2. Run your playbook to provision the node:

```diff
ansible-playbook ./play-books/aws-create-ans-client-3.yml
```

TASK [Provision node] *************************************************************************
changed: [localhost]

PLAY RECAP ************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


3. Let's check our inventory:

```diff
ansible-inventory --graph
```

The ans-client-3 is shown in the webservers group. 


4. Optional - Run the "aws-list-public-ip-addresses.yml", get the public IP address and ssh into the node using your private key. 

```diff
ansible-playbook ./play-books/aws-list-public-ip-addresses.yml
```

# Check terraform for existence of ans-client-3

We now have a resource that was configured external to our terraform configuration. This is not uncommon. It's similar to adding IaC with terraform to an exiting infrastructure. Let's check terraform for the status of this node.


1. CD to the main terraform direct and run terraform plan
   
```diff
terraform plan
```
Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed

The above is expected as terraform is only managing resources in its state file. 


2. Run the terraform state lis and observe the module.nodes.aws_instance resources

 ```diff
terraform state list
```

There is no reference to ec2-ans-client-3. Let's import it.

# Terraform Import


We will import the ec2-ans-client-3 to a local copy of our terraform state file. Verify the configuration is accurate and the upload the modified state file.


1. Make two backup copies of main.tf

```diff
cp main.tf main.tf-s3
```
and 
```diff
cp main.tf main.tf-local
```


2. Edit the "main.tf-local" and remove the terraform stanza with the S3 backend and "required providers" leaving the other modules in place.


3. Remove the terraform lock file ".terraform.lock.hcl" and the ".terraform" subdirectory. 

```diff
rm -rf .terr*
```


4. Next we'll copy the terraform state file from the S3 bucket into our main terraform directory.

```diff
aws s3 cp s3://tfstate-aws-bucket-23423f/aws-test/terraform.tfstate ./
```


5. The state file should be local

```diff
ls -l terraform.tfstate
```


6. Now that you have a local copy of the state file, initial terraform

```diff
terraform init
```

Initializing the backend...
Initializing modules...


7. Next run the "terraform plan" and ensure our state file is in sync with our terraform configuration

```diff
terraform plan
```
Terraform has compared your real infrastructure against your configuration and found no
differences, so no changes are needed.


8. Change directory to the terraform nodes directory and create a file "ans-client-3.tf" for the aws_instance resource "ans_client_3" 

./nodes/ans-client-3.tf
```diff
resource "aws_instance" "ans_client_3" {

}
```

There are no values yet. We will update this after the import. 


9. Use the aws ec2 command or the "aws-get-ec2-info.yml" playbook to get the instance ID number for ans-client-3

```diff
aws ec2 describe-instances --filters "Name=tag:Name,Values=ans-client-3"
```
   
10. Create a "import-ans-client3.sh" shell script in the main terraform directory 

```diff
terraform import module.nodes.aws_instance.ans_client_3 "i-05a7a2ef43af3fbfa"

```

Here we are importing the "aws_instance"  from module "nodes" with a resource name of "ans_client_3" that has an instance_id of "i-05a7a2ef43af3fbfa" which matches the settings in step 9 above (excluding the instance_id)

11. Execute the "import-ans-client3.sh" script

module.nodes.aws_instance.ans_client_3: Importing from ID "i-05a7a2ef43af3fbfa"... <br>
module.nodes.aws_instance.ans_client_3: Import prepared! <br>
  Prepared aws_instance for import <br>
module.nodes.aws_instance.ans_client_3: Refreshing state... <br>[id=i-05a7a2ef43af3fbfa] <br>
module.nodes.data.aws_ami.amzn-linux-2023-ami: Reading... <br>
module.nodes.data.aws_ami.amzn-linux-2023-ami: Read complete after 0s <br> [id=ami-04e5276ebb8451442] <br>

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.


12. The ans_client_3 has been added to your local terraform.tfstate file.  List the files in the terraform directory. Notice there is a new file "terraform.tfstate.backup" which is the version that was copied from s3. Use a text editor or Virtual Studio Code to open the terraform.tfstate and search for "ans_client_3" to see the node in the state file. 

Build the ./nodes/ans-client-3.tf using ans-client-1.tf as a template.

./nodes/ans-client-3.tf
```diff
resource "aws_instance" "ans_client_3" {
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      # Ignore changes to security_groups
      security_groups
    ]
  }

  ami             = data.aws_ami.amzn-linux-2023-ami.id
  key_name        = var.key-name
  security_groups = var.aws_secure_group_id
  instance_type   = "t2.nano"
  subnet_id       = var.private_playground_subnet_us_east_1a_id


  tags = {
    Name = "ans-client-3", webserver = "true"
  }
}

```


Run terraform plan to verify. If the ec2-ans-client-3.tf is configured correctly there should be no changes. If not, adjust the ec2-ans-client-3.tf until it does npt.

The import of ec2-ans-client-3 was successful and the terraform state has been verified. Next step is to push the updated terraform.tfstate to S3 and reconfigure terraform to use the S3 back-end.


13. Copy the local version of terraform.tfstate to S3

```diff
aws  s3 cp ./terraform.tfstate s3://tfstate-aws-bucket-23423f/aws-test/
```
upload: ./terraform.tfstate to s3://tfstate-aws-bucket-23423f/aws-test/terraform.tfstate 


14. Rename or delete the local copies of "terraform.tfstate" and 


15. Delete the ".terraform.lock.hcl" file and the ".terraform" subdirectory.


16. Copy "main.tf-s3" to "main.tf" to re-enable S3 as the terraform backend.


17. Run 'terraform init" to initialize the backend.   

```diff

terraform init
```
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.


18. Final step is to run "terraform plan" to ensure our terraform config and the S3 terraform state are in-sync.

```diff
terraform plan
```
Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed


19. Congratulations !! You have successfully imported an externally created resource into the terraform configuration. 


20. Finally, rename the  "ec2-ans-client-3.tf" to "ec2-ans-client-3.tf-keep" and run "terraform plan" and "terraform apply" to destroy the node. This is additional confirmation that terraform is managing the ec2-ans-client-3 resource.


"Terraform will perform the following actions:"

  "# module.nodes.aws_instance.ans_client_3 will be destroyed"


Optional: Use the ansible playbook to configure nginx on this node before deleting.


21.  Unsure if it's worth it?  See [Why Infrastructure as Code](./Why-Infrastructure-as-Code.md)

