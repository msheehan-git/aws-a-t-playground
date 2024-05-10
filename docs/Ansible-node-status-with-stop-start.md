[Return to main page](../README.md)

# Ansible EC2 Node Status with Stop and Start

In this section we'll be using the  aws.ec2_instance and aws.ec2_info modules to see the state of the nodes and later add playbooks to manage that state..  Let's start by getting some info about the node.

# Check the status of the nodes. 

1. In the play-books directory create a file called aws-list-all-running-nodes.yml

./play-books/aws-list-all-running-nodes.yml
```diff
---
- name: List ec2 nodes that are running
  hosts: localhost
  gather_facts: false

  tasks:
    - name: get ec2 instance info
      ec2_instance_info:
        filters:
          instance-state-name: ["running"]
        region: us-east-1
      register: ec2_info

    - name: Print details of ec2_info
      ansible.builtin.debug:
        msg: "{{ ec2_info }}"

```


This playbook is checking the status of the nodes in AWS and not on hosts in our inventory. Here we set the target "hosts" to localhost to run the "ec2_instance_info" module. We've added a filter for instance-state-name: ["running"] to list only active nodes. 

The last step in the local_action task is "register" . The register step records the output from the module and stores in a variable called "ec2_info".  We then use this variable in debug module to print the results. 


2. Run the playbook and observe the results:

```diff
ansible-playbook ./play-books/aws-list-all-running-nodes.yml
```


We only have two nodes, yet there's quite a bit of put. Let's capture that any only print the node and state.


3.  Edit the aws-list-all-running-nodes.yml and update the debug task.

./play-books/aws-list-all-running-nodes.yml
```diff
    - name: Print details of ec2_info
      ansible.builtin.debug:
        msg:  "Instance: {{ item.tags.Name }} is {{ item.state.name }}. "
      loop: "{{ ec2_info['instances'] }}"
      loop_control:
        label: "{{ item.tags.Name }}"

   # - name: Print details of ec2_info
   #   ansible.builtin.debug:
   #     msg: "{{ ec2_info }}"

   ```

 Here we are creating a loop for the "instances' field in the ec2_info variable. We give each iteration of the loop a name which is pulled from the "tags" field. Finally we send that to "debug" and print out with the tags.Name and state of the instance. We'll come back to this in a bit.

4. Let's see how else we can leverage this code. Recall in the terraform guides we used the AWS CLI "aws ec2 describe-instances " to query the state of the nodes and get the IP address. We'll do something similar with ansible.

Copy "aws-list-all-running-nodes.yml" to "aws-list-public-ip-addresses.yml"

Change the Play name

  ```diff
  - name: List the public IP for ec2 nodes that are running
  ```
  
Next change the debug task name and msg to display the public IP

  ```diff
      - name: Print the public IP address
      ansible.builtin.debug:
        msg:  "Instance: {{ item.tags.Name }}  public IP address is {{ item.public_ip_address }}. "

  ```

Now run the playbook and see the results

  ```diff
  ansible-playbook ./play-books/aws-list-public-ip-addresses.yml
  ```

Now ypu can quickly get the IP address of any node in the environment and ssh into it. 


5. We've done a lot getting info from the nodes now we'll do something to them.  Copy "aws-list-all-running-nodes.yml" to "aws-stop-all-running-nodes.yml'  Seeing a pattern here?  Once you have a working block of code you can expand on it, add new or different functionality. This creates consistency in the code and cuts down on development time. 

Edit aws-stop-all-running-nodes.yml and change the Play name to:

```diff
---
- name: Stop all active nodes
```

Our code already knows the state of the nodes and the instance ID that we pulled from the ec2_instance_info. We are going to pass that to the ec2_instance module and take action.  Add the next task

```diff
    - name: stop all
      ec2_instance:
        instance_ids: "{{item.instance_id}}"
        region: us-east-1
        state: stopped
        wait: yes
      with_items: "{{ec2_info.instances}}"
```

We're using the ec2_info variable again checking state of the "instance_id" and setting any nodes not "stopped" to stop. The ec2_info variable was created using a filter of "instance-state-name: ["running"]" so each instance in the variable will require a change to stopped.  The ec2_instance module has an option called "wait" that will wait for any change in state. 

Side note:

To see all the options for the ec2_instance module use ansible-doc 

```diff
ansible-doc ec2_instance 
```

To see all the available ansible modules use

```diff
ansible-doc -t module -l 
```

Back to our stop playbook...

Add the following two tasks

```diff
    - name: get ec2 instance info after stop
      ec2_instance_info:
        region: us-east-1
      register: ec2_info_post

    - name: Print details of instance_info of all nodes
      ansible.builtin.debug:
        msg:  "Instance: {{ item.tags.Name }} is {{ item.state.name }}. "
      loop: "{{ ec2_info_post['instances'] }}"
      loop_control:
        label: "{{ item.tags.Name }}"

```

Here we creating a new variable "ec2_info_post" from the ec2_instance_info module after the nodes have been stopped. The second task again uses the info from the variable to display the state. Notice the variable in the loop has changed to match the task above it. 

Run the playbook

```diff
ansible-playbook ./play-books/aws-stop-all-running-nodes.yml
```

The final step shows that all nodes have been stopped.

6. Now we'll start the nodes again. Copy "aws-stop-all-running-nodes.yml" to.... guess? "aws-start-all-nodes.yml" Yes, leverage the existing code, change the names to Start and change the states, and run the playbook.

```diff
--
- name: Start all stopped nodes
  hosts: localhost
  gather_facts: false

  tasks:
    - name: get ec2 instance info of stopped nodes.
      ec2_instance_info:
        filters:
          instance-state-name: ["stopped"]
        region: us-east-1
      register: ec2_info

    - name: Print details of ec2_info
      ansible.builtin.debug:
        msg:  "Instance: {{ item.tags.Name }} is {{ item.state.name }}. "
      loop: "{{ ec2_info['instances'] }}"
      loop_control:
        label: "{{ item.tags.Name }}"

    - name: start all
      ec2_instance:
        instance_ids: "{{item.instance_id}}"
        region: us-east-1
        state: running
        wait: yes
      with_items: "{{ec2_info.instances}}"

    - name: get ec2 instance info after stop
      ec2_instance_info:
        region: us-east-1
      register: ec2_info_post

    - name: Print details of instance_info of all nodes
      ansible.builtin.debug:
        msg:  "Instance: {{ item.tags.Name }} is {{ item.state.name }}. "
      loop: "{{ ec2_info_post['instances'] }}"
      loop_control:
        label: "{{ item.tags.Name }}"

```


7. With the nodes back to running state let's make some changes to the OS [Ansible OS Updates and Inventory Groups](./Ansible-OS-Updates-and-Inventory-Groups.md)



   
