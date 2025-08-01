data "aws_key_pair" "keypair" {
  key_name = "vockey"
}

# Create a EC2 Instance with Node Red
resource "aws_instance" "Bastion_Host" {
  ami           = data.aws_ssm_parameter.AL2023AMISSM.value
  instance_type = "t3.nano"
  credit_specification {
    cpu_credits = "standard"
  }
  vpc_security_group_ids = [
    aws_security_group.SSH_Security_Group.id,
    # aws_security_group.Node_Red_Security_Group.id,
    aws_security_group.Out_Security_Group.id
  ]
  subnet_id                   = aws_subnet.Public_Subnet2.id
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.keypair.key_name
  user_data = templatefile(
    "user_data.sh", {
      efs_dns           = aws_efs_file_system.Node_Red_EFS.dns_name,
      noderedService    = file("nodered.service"),
      refreshLabService = file("refreshLab.service"),
      refreshLabTimer   = file("refreshLab.timer"),
      refreshLabScript = templatefile("refreshLab.sh", {
        cookies = data.external.getCookies.result.result
        # cookies = ""
      }),
      pemFile = file("labsuser.pem"),

    }
  )
  depends_on = [
    aws_efs_mount_target.Node_Red_EFS_Mount_Target2,
    aws_efs_file_system.Node_Red_EFS,
    local_file.nodeRed_settings,
    local_file.nodeRed_flows,
    local_file.backup_vars,
    aws_internet_gateway_attachment.igw_attachment,
    aws_vpc_security_group_ingress_rule.SSH_Rule,
    aws_vpc_security_group_ingress_rule.EFS_Rule2,
    aws_vpc_security_group_egress_rule.Out_Rule,
    aws_route_table_association.Public_Route_Table_Association2,
    aws_route_table_association.Private_Route_Table_Association2,
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
    script = "createBackup.sh"
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
output "Bastion_Server_Public_IP" {
  value = aws_instance.Bastion_Host.public_ip
}
