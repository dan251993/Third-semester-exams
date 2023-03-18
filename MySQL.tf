resource "aws_db_instance" "mysql_rds" {
  depends_on             = [aws_security_group.MySg]
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  publicly_accessible    = var.publicly_accessible
  port                   = var.port
  vpc_security_group_ids = [aws_security_group.MySg.id]
}

output "rds_host" {
  value = aws_db_instance.mysql_rds.endpoint
}
