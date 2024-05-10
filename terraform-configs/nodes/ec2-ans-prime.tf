
resource "aws_instance" "ans_prime" {
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      # Ignore changes to security_groups
      security_groups
    ]
  }

  ami             = data.aws_ami.amzn-linux-2023-ami.id
  key_name        = var.key-name
  security_groups = var.aws_secure_group_id
  instance_type   = "t2.nano"
  subnet_id       = var.private_playground_subnet_us_east_1a_id


  tags = {
    Name = "ans-prime"
  }
}
