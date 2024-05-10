[Return to main page](../README.md)

# Create and Configure the AWS Account.


## Access AWS Web Services and provide credentials.

1. Go to the AWS Console and create your account [https://aws.amazon.com](https://aws.amazon.com) and click "Create an AWS Account"

2. The "Root user" will be an email address that is accessible and will be used to login to the web console. You can create other users that also have access to the console as IAM users.

3. The "AWS account name" is the name of the account, which is displayed in the upper right corner after logging in. This can be modified after creation. 

4.  AWS wil then prompt for additional billing information, etc. Reminder - there will be some charges using this project. This can range from a few cents per month to a few dollars. 

5. Enable Multi-factor authentication (MFA) for root user.  This is not required but is certainly recommended. There are several MFA options. The Google Authenticator app is eay to use for personal accounts which can be found on Google Play or Apple App Store. 

6. The next step is to manually configure AWS services and keys that will be consumed by our Infrastructure as Code (IaC). [Configure AWS Services](./Configure-AWS-Services.md)

