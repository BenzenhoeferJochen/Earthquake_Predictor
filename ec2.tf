data "aws_key_pair" "keypair" {
  key_name = "vockey"
}

# Create a EC2 Instance with Node Red
resource "aws_instance" "Node_Red_Server" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.SSH_Security_Group.id,
    aws_security_group.HTTP_Security_Group.id,
    aws_security_group.Out_Security_Group.id
  ]
  subnet_id                   = aws_subnet.Public_Subnet1.id
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  user_data = templatefile(
    "user_data.sh", {
      # db_address        = aws_db_instance.Wordpress_DB.address,
      # db_port           = aws_db_instance.Wordpress_DB.port,
      db_address        = "localhost"
      db_port           = "3306",
      db_password       = var.DB_PASSWORD,
      refreshLabService = file("refreshLab.service"),
      refreshLabTimer   = file("refreshLab.timer"),
      refreshLabScript = templatefile("refreshLab.sh", {
        cookies = data.external.getCookies.result.result
        # cookies = ""
      })

    }
  )
}

output "EC2_Instance_Public_IP" {
  value = aws_instance.Wordpress_Server.public_ip
}
