[Return to main page](../README.md)

# Ansible Configuration and Inventory

The main ansible configuration file is ansible.cfg. You can have ansible.cfg files in several subdirectories. Ansible will process based on the current working directory.  In this project we will only have one ansible.cfg. 

# Inventory

We'll start with the inventory file. This project will be configured for dynamic inventory. This will enable ansible to have immediate access to ec2 nodes that are provisioned by terraform. To do that, ansible requires access to the AWS account. We'll do that with variables.

1.  Create a variable called AWS_ACCESS_KEY that contains the value of your AWS Access key.

export AWS_ACCESS_KEY=******

Note: Forgot your keys?  The not-so-secret-sauce can be found here:

```diff
cat  ~/.aws/credentials
```

2. Create another variable called AWS_SECRET_ACCESS_KEY that references the aws_secret_access_key in your credentials file.  

export AWS_SECRET_ACCESS_KEY=******

3. Create a subdirectory for the ansible project called ansible-configs and create a file called aws_ec2.yml

./aws_ec2.yml
```diff
plugin: amazon.aws.aws_ec2
aws_access_key: "{{ lookup('env', 'AWS_ACCESS_KEY') }}"
aws_secret_key: "{{ lookup('env', 'AWS_SECRET_ACCESS_KEY') }}"
regions: us-east-1

```

Here we're using the amazon.aws.aws_ec2 plugin to query inventory and setting the credentials to come from the variables we exported earlier. This project is using the us-east-1 region.  You can define multiple regions 

Example:
```diff
regions:
  - us-east-1
  - us-east-2
```

4. Let's create our initial ansible.cfg.

./ansible.cfg
```diff
[defaults]
inventory=./aws_ec2.yml
host_key_checking=False
UserKnownHostsFile=/dev/null
aws_access_key=$AWS_ACCESS_KEY
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
private_key_file=$SSH
remote_user=ec2-user

```
 
 Notes:  <br>
 The "inventory" is the aws_ec2.yml we created above.  <br>
 "host_key_checking" is false as the keys may change if terraform recreates the node.   <br>
 "UserKnownHostsFile=/dev/null" is set to null. No need to maintain since we are not checking the host keys.  <br>
 The "aws_access_key" and  "aws_secret_access_key" are using the same variable we exported for aws_ec2.yml.   <br>
 "private_key_file"  is the variable we created in the [Provision EC2 Nodes](./Provision-EC2-Nodes.mdProvision-EC2-Nodes.md) and will be used ny ansible to ssh into the nodes.   <br>
 "remote_user" is the default user created during EC2 provisioning and is the same as we're using for terraform. It can be set to any account on the system. <br>
 

 5. The ansible.cfg and inventory files are created. Let's use the ansible built in ping module to verify access for all hosts. 

 ```diff
 ansible all -m ansible.builtin.ping
 ```
 ip-172-31-32-180.ec2.internal | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: ssh: Could not resolve hostname ip-172-31-32-180.ec2.internal: nodename nor servname provided, or not known",
    "unreachable": true

 Ansible is attempting to connect to the private IP. We'll update our inventory to refer to the public interface.

 
 6. Edit aws_ec2.yml and set the hosts to public IP. 

 ```diff
 plugin: amazon.aws.aws_ec2
 aws_access_key: "{{ lookup('env', 'AWS_ACCESS_KEY') }}"
 aws_secret_key: "{{ lookup('env', 'AWS_SECRET_ACCESS_KEY') }}"
 regions: us-east-1

 compose:
   ansible_host: public_ip_address

```

6. Run ping again.


 ```diff
 ansible all -m c
 ```
 ip-172-31-32-180.ec2.internal | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,
    "ping": "pong"
}

We see the successful "pong" message in the reply. This is a basic test to verify our configuration and communication. 

7. Now that our ansible configuration and inventory are set let's [Create ping playbook](./Create-ping-playbook.md)
