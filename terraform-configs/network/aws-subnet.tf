resource "aws_subnet" "private_playground_subnet_us_east_1a" {
  vpc_id                  = var.playground_vpc_id
  availability_zone       = "us-east-1a"
  cidr_block              = "172.31.32.0/24"
  map_public_ip_on_launch = "true"
}
