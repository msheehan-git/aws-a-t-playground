resource "aws_vpc" "playground_vpc" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = "playground_vpc"
  }
}
