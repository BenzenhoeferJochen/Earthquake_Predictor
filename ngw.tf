# NAT Gateway for the private subnets
resource "aws_eip" "natGatewayEIP" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natGateway" {
  allocation_id     = aws_eip.natGatewayEIP.id
  subnet_id         = aws_subnet.Public_Subnet1.id
  connectivity_type = "public"

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route" "natGatewayRoute" {
  route_table_id         = aws_route_table.Private_Route_Table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natGateway.id
}