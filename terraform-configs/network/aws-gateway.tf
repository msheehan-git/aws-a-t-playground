resource "aws_internet_gateway" "playground_gw" {
  vpc_id = var.playground_vpc_id
}
