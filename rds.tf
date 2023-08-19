/*
locals {
  Owner = "374278"
}
*/
# Step1: Create DB Subnet Group
resource "aws_db_subnet_group" "db-subnet-grp" {
  subnet_ids = aws_subnet.db-subnet[*].id
}

# Step2: Create DB Cluster
resource "aws_rds_cluster" "db-cluster" {
  depends_on         = [aws_db_subnet_group.db-subnet-grp, aws_security_group.db_sec_grp]
  cluster_identifier = "postgresql-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = var.db_engine_mode
  engine_version     = var.db_engine_version
  database_name      = "mydb"
  master_username    = "adminaccount"
  //master_password    = data.aws_secretsmanager_secret_version.current_secrets.secret_string
  master_password                     = random_password.db_master_pwd.result
  port                                = 5432
  enable_http_endpoint                = true
  skip_final_snapshot                 = true
  vpc_security_group_ids              = [aws_security_group.db_sec_grp.id]
  db_subnet_group_name                = aws_db_subnet_group.db-subnet-grp.name
  storage_encrypted                   = true
  iam_database_authentication_enabled = false
  //availability_zones                  = data.aws_availability_zones.available_az[*].id
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

# Step3: Create DB Cluster Instances
resource "aws_rds_cluster_instance" "db-cluster-instance" {
  depends_on           = [aws_rds_cluster.db-cluster]
  count                = length(data.aws_availability_zones.available_az.names)
  identifier           = "postgresql-node[${count.index + 1}]"
  cluster_identifier   = aws_rds_cluster.db-cluster.id
  instance_class       = var.db_instance_type
  engine               = aws_rds_cluster.db-cluster.engine
  engine_version       = var.db_engine_version
  db_subnet_group_name = aws_db_subnet_group.db-subnet-grp.name
  publicly_accessible  = false
}
