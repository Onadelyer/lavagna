resource "aws_db_instance" "rds" {
  instance_class = var.db_instance_class
  engine         = var.db_engine
  engine_version = var.db_engine_version
  identifier     = var.db_identifier

  username       = var.db_username
  password       = var.db_password

  allocated_storage = var.db_allocated_storage
}
