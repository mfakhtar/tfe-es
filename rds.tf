resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "postgres"
  engine_version         = "12.5"
  instance_class         = "db.t3.micro"
  username               = "fawaz"
  password               = "Welcome123"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.fawaz-tfe-es-db-sg.id
  vpc_security_group_ids = [aws_security_group.fawaz-tfe-es-sg-db03.id]
}

resource "aws_db_subnet_group" "fawaz-tfe-es-db-sg" {
  name       = "fawaz-tfe-es-db-sg"
  subnet_ids = local.private_subnets

  tags = {
    Name = "fawaz-tfe-es-db-sg"
  }
}