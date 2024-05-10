[Return to main page](../README.md)

# Ansible Ping Playbook

Ansible Playbooks are a set of task that run on system in your inventory.  Here wil create a simple "ping" playbook 

1. Create a subdirectory called play-books under the ansible-configs directory. 

2. Create a file called ping-all.yml

./play-books/ping-all.yml

```diff
---
- name: Demo of ping
  hosts: all
  gather_facts: false
  tasks:
   - name: Ping all hosts
     ansible.builtin.ping:

   - name: Print custom message
     ansible.builtin.debug:
      msg: It works!

```

Here we set a name of our playbook called "Demo of ping". The target hosts is "all".   There are two tasks in this play: "Ping all hosts" and "Print custom message". Note that the first task is running ansible.builtin.ping. This is the same module we ran using ansible command with an added second step in the playbook. 

We also set "gather_facts: false". Ansible will connect to and gather facts of the targeted host by default. If your playbook doesn't require these facts set to false to improve performance. 

Note the very first line of the playbook is "---". 

3. Let's run this to see results. Use the "ansible-playbook" command with a path to the playbook. 

```diff
ansible-playbook ./play-books/ping-all.yml
```

ok: [ip-172-31-32-214.ec2.internal] => {
    "msg": "It works!"
}
ok: [ip-172-31-32-180.ec2.internal] => {
    "msg": "It works!"
}

Note that the message returned is not "pong" The "Ping all hosts" task was successful and then the second task executed to print the custom message. We'll be using the "ansible.builtin.debug" frequently in this project. 

4. Edit the aws_ec2.yml and change public_ip_address to private_ip_address.  Run the playbook again.

Note that the "Ping all hosts' task failed and "Print custom message" never executed.  Playbooks will not proceed with subsequent tasks if one fails. However, you can code error handling to allow it, We'll look at that later. 

Set the aws_ec2.yml back to pubic_ip_address

5. Next we'll work with the AWS EC2 nodes that we created with terraform. [Ansible EC2 Node Status with Stop and Start](./Ansible-node-status-with-stop-start.md)
