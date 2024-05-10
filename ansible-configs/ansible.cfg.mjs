[defaults]
host_key_checking=False
UserKnownHostsFile=/dev/null
allow_duplicated_hosts=false
aws_access_key=$AWS_ACCESS_KEY
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
private_key_file=$SSH
inventory=./aws_ec2.yml
remote_user=ec2-user
#ansible_python_interpreter=/usr/bin/python3
#interpreter_python=/usr/bin/python3
