# AWS Ansible and Terraform Playground 

Welcome to the AWS A-T Playground. The purpose of this project is to gain experience on the Amazon Web Services platform (AWS) and Infrastructure as Code with Ansible and Terraform. This isn't intended as a teaching project. There are plenty of other resources for that. The goal of this project is to present sets of code that can be copy/pasted to manage resources in AWS and perhaps trigger a desire to continue exploring. 

The demonstration modules will focus on the AWS Free tier which will limit the services used. It should be noted that there will be some costs incurred and AWS will require a credit card to create your account. You can implement cost controls by turning off or deleting resources when not in use. However, there are components such as storage that will continue to use billable resources. The AWS Web Console does display a summary of charges on the main page.

Although ansible and terraform can boh create resources in AWS, for this project we're using terraform to manage the infrastructure and ansible to manage the configuration of it. 

This will be a living project and I will be adding additional and more complex modules as time allows.  

  

#   AWS Account Setup and Client Installation

1. [Creating your AWS Account](./docs/Create-AWS-Account.md) 

2. [Configure AWS Services](./docs/Configure-AWS-Services.md)

3. [Install and Configure the AWS CLI](./docs/Install-Configure-AWS-CLI.md)


#   Terraform CLI Installation  

1. [Install Terraform](./docs/Install-Terraform.md). 


#   Configure AWS using Terraform

1.  [Configure S3 and Provision VPC](./docs/Configure-S3-and-Provision-VPC-Terraform.md) 

2.  [Provision AWS Network](./docs/Provision-AWS-Network.md)

3.  [Create Security Group](./docs/Create-Security-Group.md)

4.  [Provision EC2 Nodes](./docs/Provision-EC2-Nodes.md)


#   Ansible CLI Installation

1. [Install Ansible](./docs/Install-Ansible.md)
2. [Create ansible configuration and inventory](./docs/Create-ansible-configuration-and-inventory.md)


# Ansible CLI and Playbooks

1.  [Create ping playbook](./docs/Create-ping-playbook.md)
2.  [Ansible EC2 Node Status with Stop and Start](./docs/Ansible-node-status-with-stop-start.md)
3.  [Ansible OS Updates and Inventory Groups](./docs/Ansible-OS-Updates-and-Inventory-Groups.md)
4.   [Ansible Install Packages and Bootstrap](./docs/Ansible-Install-Packages-and-Bootstrap.md)


# Summary 
1. [Why Infrastructure as Code](./docs/Why-Infrastructure-as-Code.md)

2. [Terraform vs Ansible](./docs/Terraform-vs-Ansible.md)

4. [Planned Updates for the playground](./docs/Planned-Updates.md)
