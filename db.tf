resource "aws_db_instance" "Node_Red_DB" {
  allocated_storage        = 5
  multi_az                 = false
  db_name                  = var.DB_DATABASE
  engine                   = "mysql"
  engine_version           = "8.4"
  instance_class           = "db.t3.micro"
  password_wo              = var.DB_PASSWORD
  username                 = "root"
  password_wo_version      = "1.0"
  storage_type             = "gp2"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  vpc_security_group_ids   = [aws_security_group.DB_Security_Group.id, aws_security_group.Out_Security_Group.id]
  db_subnet_group_name     = aws_db_subnet_group.node_red_db_subnet_group.name
  publicly_accessible      = false
  backup_retention_period  = 0
  skip_final_snapshot      = true
}
