resource "aws_route_table_association" "allow_all_inbound" {
  subnet_id      = aws_subnet.private_playground_subnet_us_east_1a.id
  route_table_id = aws_route_table.allow_all_inbound.id
}
