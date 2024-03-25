output "rds-instance-endpoint" {
  value = aws_db_instance.demobank-rds-pgsql.endpoint
}

output "rds-instance-id" {
  value = aws_db_instance.demobank-rds-pgsql.id
}

output "db-name" {
  value = aws_db_instance.demobank-rds-pgsql.db_name
}

output "username" {
  value = aws_db_instance.demobank-rds-pgsql.username
}

output "password" {
  value = aws_db_instance.demobank-rds-pgsql.password
}