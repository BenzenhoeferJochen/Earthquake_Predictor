
# Create a VPC
resource "aws_vpc" "Node_Red_VPC" {
  cidr_block = "10.0.0.0/26"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create a Route Table
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.Node_Red_VPC.id
}

resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.Node_Red_VPC.id
}
