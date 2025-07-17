# A EFS attached to the Node Red EC2 instance
resource "aws_efs_file_system" "Node_Red_EFS" {
  creation_token = "Node_Red_EFS"
  performance_mode = "generalPurpose"
  tags = {
    Name = "Node_Red_EFS"
  }
}

# Create a mount target for the EFS in the private subnet
resource "aws_efs_mount_target" "Node_Red_EFS_Mount_Target" {
  file_system_id = aws_efs_file_system.Node_Red_EFS.id
  subnet_id      = aws_subnet.Private_Subnet1.id
  security_groups = [aws_security_group.EFS_Security_Group.id]
}

