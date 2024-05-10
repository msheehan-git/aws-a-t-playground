[Return to main page](../README.md)

# Planned Updates

We covered some basic concepts here. I have a few modules in progress that I wil be adding as time allows. 


1. Templates: terraform and ansible each support templates. We'll focus on that and how it makes IaC even more robust. 

2. Managing the terraform state file: We'll import existing infrastructure and manually upload a new state file to S3. We'll also manipulate the state file to move resources as templates are introduced. 

3. Importing ansible playbooks: We ran self contained playbooks mainly by coping code and adding to it. Ansible supports importing tasks. We'll demo having a set of tasks and building playbooks that use them. 

4. More demos of the ansible cli: The focus of the playground was on automation and tying terraform and ansible using the playbooks.  There is a benefit im providing additional examples running the modules using ansible cli.

5. Creating the ansible control node: We ran everything from our workstations. The next update will start using ans-prime as the ansible server. The playbook is there if you want to try (install_prime-packages.yml). I needed make this project public first to demo git pull and keeping ans-prime current. 
   
6. Create S3 with terraform and add to nginx: We'll provision a new S3 bucket and add it the web servers for a more production-like use case. 

7. Adding more AWS resources: Pushing the limits of the "free' services to gain more experience. 

8. Provision and configure a Jenkins server: This is where the power of automation can really be seen.  We'll provision a Jenkins server with jobs that monitor this project and use it to show a CI/CD pipeline. 
