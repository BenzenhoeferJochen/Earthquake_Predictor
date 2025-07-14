resource "local_file" "nodeRed_settings" {
  content = templatefile("${path.module}/Node-Red-Template/settings.js", {
    credentialSecret = var.CREDENTIAL_SECRET

  })
  filename = "${path.module}/Node-Red/settings.js"
}

resource "local_file" "nodeRed_flows" {
  content = templatefile("${path.module}/Node-Red-Template/flows.json", {
    db_address        = aws_db_instance.Node_Red_DB.address,
    db_port           = aws_db_instance.Node_Red_DB.port,
    db_database       = var.DB_DATABASE

  })
  filename = "${path.module}/Node-Red/flows.json"
}
