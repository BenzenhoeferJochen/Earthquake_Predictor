# Create a SSH Security Group
resource "aws_security_group" "SSH_Security_Group" {
  description = "Allows SSH Access for Me"
  name        = "SSH_Security_Group"
  vpc_id      = aws_vpc.Wordpress_VPC.id
}

# Allow SSH ingress
resource "aws_vpc_security_group_ingress_rule" "SSH_Rule" {
  security_group_id = aws_security_group.SSH_Security_Group.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${data.http.myip.response_body}/32"
}

# Allow SSH ingress
resource "aws_vpc_security_group_ingress_rule" "SSH_Rule2" {
  security_group_id = aws_security_group.SSH_Security_Group.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  referenced_security_group_id = aws_security_group.SSH_Security_Group.id
}

# Create a Node_Red Security Group
resource "aws_security_group" "Node_Red_Security_Group" {
  description = "Allows Node_Red Access for everyone"
  name        = "Node_Red_Security_Group"
  vpc_id      = aws_vpc.Node_Red_VPC.id
}

# Allow Node_Red ingress
resource "aws_vpc_security_group_ingress_rule" "Node_Red_Rule" {
  security_group_id = aws_security_group.Node_Red_Security_Group.id
  ip_protocol       = "tcp"
  from_port         = 1880
  to_port           = 1880
  cidr_ipv4         = "0.0.0.0/0"
}

# Create a DB Security Group
resource "aws_security_group" "DB_Security_Group" {
  description = "Allows DB Access for Me"
  name        = "DB_Security_Group"
  vpc_id      = aws_vpc.Wordpress_VPC.id
}

# Allow DB ingress
resource "aws_vpc_security_group_ingress_rule" "DB_Rule" {
  security_group_id            = aws_security_group.DB_Security_Group.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.SSH_Security_Group.id
}

# Create a Outgress Security Group
resource "aws_security_group" "Out_Security_Group" {
  description = "Allows all outgress traffic"
  name        = "Out_Security_Group"
  vpc_id      = aws_vpc.Wordpress_VPC.id
}

# Allow all outgress 
resource "aws_vpc_security_group_egress_rule" "Out_Rule" {
  security_group_id = aws_security_group.Out_Security_Group.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}
