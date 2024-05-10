resource "aws_route_table" "allow_all_inbound" {
  vpc_id = var.playground_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.playground_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.playground_gw.id
  }

  tags = {
    Name = "allow-all-inbound"
  }
}

