[Return to main page](../README.md)

# Installing Packages and Bootstrap nodes.  

In this section we'll install the nginx package on our web sever, set it to start on reboot and test connecting to it.  We'll go back to terraform and update the security group and provision a new node. 

1.  Let's borrow the concept of upgrading all packages and install a specific package on a specific group of nodes.
   
Copy "aws-os-update.yml" to  "aws-install-nginx.yml" and make the following changes

Change the Play name and set target hosts to webservers which is the group in our inventory. 

```diff
-name: Installing nginx on nodes based on inventory group
  hosts: webservers
```

and add a new task

```diff
  - name: Use yum to install nginx
    ansible.builtin.yum:
      name: nginx
      state: present
      update_cache: true

```

Note: The state "present" instructs ansible to ensure the package is installed (aka present). To remove the package set the state to "absent"

Run the playbook.


2. Use ansible with builtin command to check the status

```diff
ansible webservers -b -m ansible.builtin.command -a "which nginx"
```

Okay it's there. Now check the if running

```diff
ansible webservers -b -m ansible.builtin.command -a "systemctl status  nginx"
```

We need to add more steps to our playbook to start nginx and set to restart on reboot.


3. Edit aws-install-nginx.yml and add the following. 

```diff
  - name: Enable nginx on reboot
    ansible.builtin.service:
      name: "nginx"
      enabled: true

  - name: Start nginx
    ansible.builtin.service:
      name: "nginx"
      state: started

```

Here we're using the built in service to set enabled=true and to start nginx.

Run the updated playbook.

Check the status again using ansible

```diff
ansible webservers -b -m ansible.builtin.command -a "systemctl status  nginx"
```
It's running, let's access it.

Run the aws-list-public-ip-addresses.yml playbok to get the public IP of ans-client-1

```diff
ansible-playbook ./play-books/aws-list-public-ip-addresses.yml
```

Use curl or a web browser to access nginx.

```diff
curl http://54.198.67.165
```
curl: (28) Failed to connect to 54.198.67.165 port 80 

Any guess as to why? Recall in the terraform section we created a security group that restricted inbound access to only port 22.  Let's return to terraform and add a new ingress rule.


4. Return to the terraform-configs/secure directory.

Edit the limited-access-grp.tf and add a new ingress section for your personal IP and set the port to 80. 

./secure/limited-access-grp.tf
```diff
  ingress {

    cidr_blocks = [
      "192.168.2.25/32",
      "18.206.107.24/29"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "192.168.2.25/32"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
   }

```

Change into the main terraform directory and run the plan and apply

```diff
terraform plan
```

```diff
terraform apply
```

  ~ update in-place

Terraform will perform the following actions:

  "# module.secure.aws_security_group.limited_access will be updated in-place"

Run the curl command again. It works! 


5. Let's continue building our nginx server. Return to the ansible-configs/play-books directory.

Create a directory called "files"

Change into the files directory and edit a file called "index.html" that contains the following text

```diff
Welcome to the AWS A-T playground.
```

Edit the "aws-install-nginx.yml" playbook and add the follow task.

```diff
  - name: Update the default nginx index
    ansible.builtin.copy:
      src: ../files/index.html
      dest: /usr/share/nginx/html
      owner: root
      group: root
      mode: u=rw,g=r,o=r

```

Here we are using the builtin.copy module to take a file from our source code and copy it to the server. 

Now run the playbook.

Next run the curl command again or access the ans-client-1 again with your browser. 

```diff
curl http://54.198.67.165
```
Welcome to the AWS A-T playground.


6. The steps above configured a single node to run nginx and used source code to update the content.  Let's see how this can ease adding future nodes to expand capacity.

Return to the terraform nodes directory and copy ec2-ans-client-1.tf to ec2-ans-client-2.tf

Edit ec2-ans-client-2.tf and change the terraform resource name and tags name.

```diff
resource "aws_instance" "ans_client_2" {
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
    Name = "ans-client-2", webserver = "true"
  }
}

```

Run terraform plan and apply to provision the new node.
   
Return to the directory with ansible.cfg and check the inventory

```diff
ansible-inventory --graph
```

The ans-client-2 is now listed in our aws_ec2 group and our web server group. However, it does not have nginx or our custom index file. Let's bootstrap ans-client-2 and make it fully functional.

Run the aws-install-nginx.yml playbook again without any modifications. 

```diff
ansible-playbook ./play-books/aws-install-nginx.yml  
```

The ans-client-2 is updated during 4 tasks. Get the pubic IP and access curl or your browser.

```diff
ansible-playbook ./play-books/aws-list-public-ip-addresses.yml
```
Then curl to the ans-client-2 

```diff
curl http://54.226.1.85/
```
Welcome to the AWS A-T playground.


Bingo! With a few clicks, we've provisioned a brand new system with the desired security settings, installed the required packages and made it available on the network with the latest code. 


7. Since we're using the terraform section again, let's run another demo.
   
Terminate the ans-client-1 instance using the aws cli.

First get the Instance ID from the "aws ec2 describe-instances"  we used earlier:

```diff
aws ec2 describe-instances --filters "Name=tag:Name,Values=ans-client-1"
```

Now use aws cli to dry-run the termination:

```diff
aws ec2 terminate-instances --instance-ids i-07f63d87a354e26ba --dry-run
```
An error occurred (DryRunOperation) when calling the TerminateInstances operation: Request would have succeeded, but DryRun flag is set

Run again without dry-run

```diff
aws ec2 terminate-instances --instance-ids i-07f63d87a354e26ba
```
{
    "TerminatingInstances": [
        {
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "InstanceId": "i-07f63d87a354e26ba",
            "PreviousState": {
                "Code": 0,
                "Name": "running"
            }
        }
    ]
}


Jump back to the main terraform director and run terraform apply. 

Since the node was deleted in the Console and not in the terraform 
directory terraform will want to recreate it.  Say "yes" to apply.

Now run the aws-install-nginx.yml  playbook once more and you have recreated ans-client-1. 

By deleting ans-client-1 demonstrated how to rebuild a system that had been previously in use.  

1. Unsure if Infrastructure as Code is worth it?  See [Why Infrastructure as Code](./Why-Infrastructure-as-Code.md)
   
