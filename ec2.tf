data "aws_key_pair" "keypair" {
  key_name = "vockey"
}

# Create a EC2 Instance with Node Red
resource "aws_instance" "Node_Red_Server" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t2.nano"
  vpc_security_group_ids = [
    aws_security_group.SSH_Security_Group.id,
    aws_security_group.Node_Red_Security_Group.id,
    aws_security_group.Out_Security_Group.id
  ]
  subnet_id                   = aws_subnet.Public_Subnet1.id
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  user_data = templatefile(
    "user_data.sh", {
      # db_address        = aws_db_instance.Node_Red_DB.address,
      # db_port           = aws_db_instance.Node_Red_DB.port,
      # db_address        = "localhost"
      # db_port           = "3306",
      # db_password       = var.DB_PASSWORD,
      noderedService    = file("nodered.service"),
      refreshLabService = file("refreshLab.service"),
      refreshLabTimer   = file("refreshLab.timer"),
      refreshLabScript = templatefile("refreshLab.sh", {
        cookies = data.external.getCookies.result.result
        # cookies = ""
      })

    }
  )
}


# Create a EC2 Instance with Python ML API
resource "aws_instance" "Python_ML_API_Server" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t2.nano"
  vpc_security_group_ids = [
    aws_security_group.SSH_Security_Group.id,
    aws_security_group.Back_End_Security_Group.id,
    aws_security_group.Out_Security_Group.id
  ]
  subnet_id                   = aws_subnet.Public_Subnet1.id
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  user_data = templatefile(
    "user_data_Backend.sh", {
      db_user     = "localhost",
      db_database = "mydatabase",
      db_address  = "localhost",
      db_port     = "3306",
      db_password = var.DB_PASSWORD
      database = templatefile("ML/database.py", {
        # db_address  = aws_db_instance.Python_ML_API_DB.address,
        # db_port     = aws_db_instance.Python_ML_API_DB.port,
        # db_password = var.DB_PASSWORD
        db_user     = "localhost",
        db_database = "mydatabase",
        db_address  = "localhost",
        db_port     = "3306",
        db_password = var.DB_PASSWORD
      })
      earthquakeMLAPI          = file("ML/earthquake_ml_api.py")
      earthquakeMLRequirements = file("ML/requirements.txt")
      earthquakeTimes          = file("ML/earthquake_times.py")
    }
  )
}

output "EC2_Instance_Public_IP" {
  value = aws_instance.Node_Red_Server.public_ip
}


output "EC2_Instance_Public_IP_2" {
  value = aws_instance.Python_ML_API_Server.public_ip
}
