
#ansible all -m ec2_instance_info -a 'filter={{ (instance-state == "pending") }}'
#ansible all -m ec2_instance_info -a 'filter={{ ("instance-state" == "pending") }}'
ansible localhost -m ec2_instance -a 'filter={{ ("instance-state" == "pending") }}'
