[Return to main page](../README.md)

# Why Infrastructure as Code (IaC)?  

If you've made it this far, congratulations! You've been doing a lot of copying and coding. You are either wondering if it's worth the effort to use IaC or your itching to do more of it.  If the latter, continue playing. Use the examples to build out your own playground.  Contribute with some PR's to share with all. Just be sure to include the corresponding documentation. If the former and you are still unsure, let's explore a few real time scenarios.

1. Automate, Automate, Automate - This playground contains simple examples that could easily be managed by using the UI. However, scale it out to hundreds of servers and the benefit becomes clearer. Using IaC you create repeatable processes with standard configurations.  You avoid Admin #1 creating web server A with 2 CPU / 8 GB and Admin #2 creating web server B with 8 and 8. Run the code and create the standard build. 

2.  Continuos Integration /  Continuous Delivery (CI/CD) - Building on the Automate above, move the steps we did in the playground to a Jenkins server and we have one job that will provision the resources via Terraform and then run the Ansible bootstrap steps. 

3. CI/CD with Change Management - A somewhat conflicting statement but large organizations need/want the controls that ServiceNow, Jira or other ticking tools provide.  Let's walk through a potential use case. 
   
   1. The OPS team creates a Pull Request (PR) that contains and update to the terraform  repository. 
   2. The OPS team creates a ticket in ServiceNow (SNOW) that's sent to the Change Management team for approvals.
   3. The Change Management team approves the ticket in SNOW. 
   4. SNOW calls out to GitHub to approve and merge the PR.
   5. The Jenkins server has a job that is monitoring commits to the main branch in Github. 
   6. Jenkins sees the merge from SNOW which triggers the job.
   7. The first step of the Jenkins job runs the terraform apply to provision the new node. 
   8. The next step runs the ansible playbook to bootstrap it and make it available. 
   9. That's it. No going to the UI. 
   10. An added benefit is the audit trail. GitHub logs the PR details. We have the SNOW logs and the logs and history from Jenkins. 
   11. Here are a couple of resources that discuss this further
      1.  [https://docs.servicenow.com/bundle/washingtondc-devops/page/product/enterprise-dev-ops/task/manage-pull-request-pipelines.html](https://docs.servicenow.com/bundle/washingtondc-devops/page/product/enterprise-dev-ops/task/manage-pull-request-pipelines.html)
      2.  [https://www.atlassian.com/devops/automation-tutorials/jira-automation-rule-pullrequest-approval](https://www.atlassian.com/devops/automation-tutorials/jira-automation-rule-pullrequest-approval)
  

4.  Disaster Recovery - If your infrastructure it managed by code, that code can be used to rebuild any broken components. As we demonstrated in the last section, terraform can provision new resources or recreate ones that existed previously. When coupled with an ansible bootstrap playbook this can become a key part of your disaster recovery plan. 

5. Terraform History - We enabled versioning for our S3 bucket. Each time terraform made an update a new version of the state file was created and the previous was maintained. Take a quick look at your state file using the aws cli:
         ```diff
        aws s3api list-object-versions --bucket tfstate-aws-bucket-23423f
        ```
We can view the historical versions to see what the infrastructure looked like at a previous point in time.     


# Is it too late to switch to IaC management?
Having an existing infrastructure does not prevent you from using IaC. Draw that line in the sand and use IaC for all resources going forward. 

Terraform has an import function which allows existing components to be added to the state file and managed by terraform. 


    
    
