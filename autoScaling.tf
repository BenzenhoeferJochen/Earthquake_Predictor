
resource "aws_launch_template" "node_red_launch_template" {
  name        = "node-red-launch-template"
  description = "Launch template for Node-Red EC2 instances"

  # Instance type
  instance_type = "t3.small"

  # AMI ID
  image_id = data.aws_ssm_parameter.AL2023AMISSM.value # Amazon Linux 2023 AMI ID

  key_name = data.aws_key_pair.keypair.key_name

  # Network configuration
  network_interfaces {
    subnet_id = aws_subnet.Public_Subnet1.id
    security_groups = [
      aws_security_group.SSH_Security_Group2.id,
      aws_security_group.Node_Red_Security_Group.id,
      aws_security_group.Out_Security_Group.id
    ]
  }

  # User data script
  user_data = base64encode(templatefile(
    "user_data_Frontend.sh", {
      efs_dns        = aws_efs_file_system.Node_Red_EFS.dns_name,
      noderedService = file("nodered.service")
    }
  ))

  # Instance tags
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "Node-Red-Server"
      Environment = "production"
    }
  }
}

# AWS Auto Scaling Group
resource "aws_autoscaling_group" "node_red_asg" {
  name = "node-red-autoscaling-group"

  # Launch template
  launch_template {
    id = aws_launch_template.node_red_launch_template.id
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # VPC zone identifier (subnets)
  vpc_zone_identifier = [
    aws_subnet.Public_Subnet1.id,
    aws_subnet.Public_Subnet2.id
  ]

  # Desired capacity
  desired_capacity = 1
  min_size         = 1
  max_size         = 4

  # Health check
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Tags
  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  # Termination policies
  termination_policies = ["OldestInstance"]

  # Cooldown period
  default_cooldown = 300

  # Instance protection
  protect_from_scale_in = false
}


resource "aws_launch_template" "backend_launch_template" {
  name        = "backend-launch-template"
  description = "Launch template for Backend EC2 instances"

  # Instance type
  instance_type = "t3.medium"

  # AMI ID
  image_id = data.aws_ssm_parameter.AL2023AMISSM.value # Amazon Linux 2023 AMI ID

  key_name = data.aws_key_pair.keypair.key_name

  # Network configuration
  network_interfaces {
    subnet_id = aws_subnet.Public_Subnet1.id
    security_groups = [
      aws_security_group.SSH_Security_Group2.id,
      aws_security_group.Back_End_Security_Group.id,
      aws_security_group.Out_Security_Group.id
    ]
  }

  # User data script
  user_data = base64encode(templatefile(
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
  ))

  # Instance tags
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "Backend-Server"
      Environment = "production"
    }
  }
}

# AWS Auto Scaling Group
resource "aws_autoscaling_group" "backend_asg" {
  name = "backend-autoscaling-group"

  # Launch template
  launch_template {
    id = aws_launch_template.backend_launch_template.id
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]

  # VPC zone identifier (subnets)
  vpc_zone_identifier = [
    aws_subnet.Private_Subnet1.id,
    aws_subnet.Private_Subnet2.id
  ]

  # Desired capacity
  desired_capacity = 1
  min_size         = 1
  max_size         = 4

  # Health check
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Tags
  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  # Termination policies
  termination_policies = ["OldestInstance"]

  # Cooldown period
  default_cooldown = 300

  # Instance protection
  protect_from_scale_in = false
}
