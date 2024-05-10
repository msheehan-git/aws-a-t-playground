resource "aws_security_group" "limited_access" {
  name = "limited_access"

  vpc_id = var.playground_vpc_id

  ingress {

    cidr_blocks = [
      "192.168.2.25/32",
      "18.206.107.24/29"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "192.168.2.25/32"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
