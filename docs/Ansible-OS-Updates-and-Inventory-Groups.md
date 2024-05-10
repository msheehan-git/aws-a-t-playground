[Return to main page](../README.md)

# Ansible OS Updates and Inventory Groups

In this section we'll add some groups to our inventory based on the tags we defined when the nodes were created. We'll then take action based on the group name.

1. Create a play that use the ansible.builtin.yum update all packages on the ans-prime node. Add "become: yes" to switch to root on the node. Create a playbook 

```diff
---
- name: Update all packages using YUM
  hosts: ans-prime
  gather_facts: false
  become: yes
  tasks:
  - name: Upgrade all packages
    ansible.builtin.yum:
      name: "*"
      state: latest

```      

Now run the playbook

```diff
ansible-playbook ./play-books/aws-os-update.yml 
```
The playbook has no action because it could not find a matching host. We can update the inventory to use the tag names.


2. Run the ansible-inventory from the ansible-configs directory and set the out to "--graph"

```diff
ansible-inventory --graph
```

Notice that our two nodes are listed in the aws_ec2 group with a hostname consisting of the private IP address. Edit the "aws_ec2.yml" and add the following section

```diff
hostnames:
- tag:Name
```

Run the inventory again with the graph output

```diff
ansible-inventory --graph
```
See how the hostname is now listed as the tag name. 


3. Run the OS update playbook again.

```diff
ansible-playbook ./play-books/aws-os-update.yml 
```

This time it finds the name of the ans-prime node and runs the task.

Run the same playbook again and notice a change in the output

"msg": "Nothing to do", "rc": 0, "results": []}"

The system is already up to date. 


4. Edit the inventory again and add an additional group.


```diff
groups:
  webservers: "'true' in tags.webserver"
```

Run the inventory again with the graph output. We now have a group with a single node "ans-client-1" in the webservers group. With this, we can create playbooks that target a specific group. 

Edit the aws-os-update.yml and change "hosts" to "webservers" and run the playbook.  This time it runs on ans-client-1 which is in the webservers group.


5. We're going to push this a bit for a demo. Here we'll use ansible to update the OS, echo the uptime. reboot the node and echo uptime again. This adds a new parameter to the play "serial: 1" which processes the hosts one at a time. The default fork for ansible is 5 hosts in parallel. Here we are restricting that just for this playbook.  Think of web severs behind a load balancer. We'll update one a time to avoid an outage.  Granted, you may be reserved about handing off OS upgrades to automation. but this is to show one method.

   
Copy "aws-os-update.yml" to "aws-os-update-and-reboot.yml" and make the following updates

```diff
---
- name: Update all packages using yum and reboot
  hosts: aws_ec2
  gather_facts: false
  become: yes
  serial: 1
```
We're using the aws_ec2 group here that we made available by upgrading the inventory above. 

Add these tasks

```diff
  - name: Run uptine command
    ansible.builtin.command: /usr/bin/uptime
    register: uptime_out

  - name: Print uptime
    ansible.builtin.debug:
      msg:  " {{ uptime_out.stdout }} "

  - name: Reboot systems after update
    ansible.builtin.reboot:

  - name: Run uptine command again
    ansible.builtin.command: /usr/bin/uptime
    register: uptime_out_post

  - name: Print uptime
    ansible.builtin.debug:
      msg:  " {{ uptime_out_post.stdout }} "

```

We're using two new modules here. The ansible.builtin.command which runs commands at the OS level. This playbook bas "become: yes" which will have the command run as "root". We're also printing out the stdout element of the variable "uptime_out" to limit output. We're rebooting the OS using the ansible.builtin.reboot module. After reboot we run uptime again and print the output. Recall earlier that the playbook stops if one task fails. This too would help avoid an outage as it will stop processing if one node fails. 

Run the playbook and notice the order the nodes are processed and the changes in "uptime" output before and after reboot task.

```diff
ansible-playbook ./play-books/aws-os-update-and-reboot.yml
```

7. Let's continue working on installing packages [Ansible Install Packages and Bootstrap](./Ansible-Install-Packages-and-Bootstrap.md)