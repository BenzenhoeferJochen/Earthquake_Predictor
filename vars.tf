variable "DB_PASSWORD" {
  type        = string
  description = "The Password for the Node-Red DB"
  sensitive   = true
}

variable "DB_USER" {
  type        = string
  description = "The User for the Node-Red DB"
  sensitive   = true
}

variable "DB_DATABASE" {
  type        = string
  description = "The Database for the Node-Red DB"
  sensitive   = true
}


variable "CREDENTIAL_SECRET" {
  type        = string
  description = "The Secret for Node-Red Credentials"
  sensitive   = true
}
