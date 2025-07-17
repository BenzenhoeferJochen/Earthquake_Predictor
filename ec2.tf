data "aws_key_pair" "keypair" {
  key_name = "vockey"
}

# Create a EC2 Instance with Node Red
resource "aws_instance" "Node_Red_Server" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t3.small"
  credit_specification {
    cpu_credits = "standard"
  }
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
      efs_dns           = aws_efs_file_system.Node_Red_EFS.dns_name,
      noderedService    = file("nodered.service"),
      refreshLabService = file("refreshLab.service"),
      refreshLabTimer   = file("refreshLab.timer"),
      refreshLabScript = templatefile("refreshLab.sh", {
        cookies = data.external.getCookies.result.result
        # cookies = ""
      })

    }
  )
  depends_on = [aws_efs_mount_target.Node_Red_EFS_Mount_Target,
    aws_efs_file_system.Node_Red_EFS,
    local_file.nodeRed_settings,
    local_file.nodeRed_flows,
    local_file.backup_vars,
    aws_internet_gateway_attachment.igw_attachment,
    aws_vpc_security_group_ingress_rule.SSH_Rule,
    aws_vpc_security_group_ingress_rule.EFS_Rule,
    aws_vpc_security_group_egress_rule.Out_Rule,
    aws_route_table_association.Public_Route_Table_Association,
    aws_route_table.Public_Route_Table,
    aws_route.IGW_Route
  ]
  provisioner "remote-exec" {
    when = create
    inline = [
      "echo 'Waiting for EFS mount...'",
      "while ! mountpoint -q /efs/nodeRed; do sleep 5; done",
      "echo 'Waiting for Permissions...'",
      "while [ ! -w /efs/nodeRed ]; do sleep 5; done"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("labsuser.pem")
    }

  }

  provisioner "local-exec" {
    when       = create
    command    = "scp -r -o StrictHostKeyChecking=no -i labsuser.pem Node-Red ec2-user@${self.public_ip}:/efs/nodeRed/.node-red"
    on_failure = continue
  }

  provisioner "remote-exec" {
    when = create
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
    inline = [
      "cd /efs/nodeRed/.node-red/Node-Red && sudo npm install",
      "sudo chown -R node-red:node-red /efs/nodeRed",
      "sudo systemctl restart nodered.service"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
    inline = [
      "set -e",
      "sudo cp -r /efs/nodeRed/.node-red/Node-Red /home/ec2-user/Node-Red-backup",
      "sudo rm -rf /home/ec2-user/Node-Red-backup/lib",
      "sudo rm -rf /home/ec2-user/Node-Red-backup/node_modules",
      "sudo chown -R ec2-user:ec2-user /home/ec2-user/Node-Red-backup",
      "echo 'Backup completed successfully.'"
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "scp -r -o StrictHostKeyChecking=no -i labsuser.pem ec2-user@${self.public_ip}:/home/ec2-user/Node-Red-backup Node-Red-Backup"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "python scripts/templetize_NodeRed_Backup.py Node-Red-Backup Node-Red-Backup-Template2 ${path.module}/tmp/backup_vars.json"
    on_failure = continue

  }

}


# Create a EC2 Instance with Python ML API
resource "aws_instance" "Python_ML_API_Server" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t3.medium"
  credit_specification {
    cpu_credits = "standard"
  }
  vpc_security_group_ids = [
    aws_security_group.SSH_Security_Group.id,
    aws_security_group.Back_End_Security_Group.id,
    aws_security_group.Out_Security_Group.id
  ]
  subnet_id                   = aws_subnet.Public_Subnet1.id
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
  user_data = templatefile(
    "user_data_Backend.sh", {
      db_user     = var.DB_USER,
      db_database = var.DB_DATABASE,
      db_address  = aws_db_instance.Node_Red_DB.address,
      db_port     = aws_db_instance.Node_Red_DB.port,
      db_password = var.DB_PASSWORD,
      database = templatefile("ML/database.py", {
        db_address  = aws_db_instance.Node_Red_DB.address,
        db_port     = aws_db_instance.Node_Red_DB.port,
        db_password = var.DB_PASSWORD
        db_user     = var.DB_USER,
        db_database = var.DB_DATABASE,
      }),
      predictionService        = file("ML/prediction.service"),
      earthquakeMLAPI          = file("ML/earthquake_ml_api.py"),
      earthquakeMLRequirements = file("ML/requirements.txt"),
      earthquakeTimes          = file("ML/earthquake_times.py")
    }
  )
}

output "Node_Red_Server_Public_IP" {
  value = aws_instance.Node_Red_Server.public_ip
}


output "Python_ML_API_Server_Public_IP" {
  value = aws_instance.Python_ML_API_Server.public_ip
}
