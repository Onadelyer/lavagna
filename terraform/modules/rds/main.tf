resource "aws_db_subnet_group" "lavagna-subnet-group" {
  name       = "lavagna-db-subnet-group"
  subnet_ids = var.public-subnets
}

resource "aws_db_instance" "demobank-rds-pgsql" {
  identifier             = "lavagna-db"
  db_name                = "lavagna"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "12.12"
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.lavagna-subnet-group.name
  vpc_security_group_ids = [var.rds-sg-id]
  username               = "myuser"
  password               = "mypassword"
}