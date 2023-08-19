/*
locals {
  Owner = "374278"
}
*/
resource "random_id" "id" {
  byte_length = var.byte_length
}

# Step 1: Create a random generated password to use in Secrets
resource "random_password" "db_master_pwd" {
  length           = 20
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Step 2: Creating an AWS secret for DB Master Account
resource "aws_secretsmanager_secret" "db-secret" {
  depends_on = [random_id.id]
  name       = "dbsecrets-${random_id.id.hex}"
  tags = {
    Name = "${local.Owner}-dbsecrets"
  }
}

# Step3: Creating an AWS Secret Version to store current secrets
resource "aws_secretsmanager_secret_version" "db-secret-version" {
  depends_on = [aws_secretsmanager_secret.db-secret]
  secret_id  = aws_secretsmanager_secret.db-secret.id
  //secret_string = random_password.db_master_pwd.result
  /*
  secret_string = jsonencode(
    {
      username = aws_rds_cluster.db-cluster.master_username
      password = aws_rds_cluster.db-cluster.master_password
      engine   = "postgres"
      host     = aws_rds_cluster.db-cluster.endpoint
    }
  )
  */
  secret_string = <<-EOF
    {
      "engine": "postgres",
      "host": "${aws_rds_cluster.db-cluster.endpoint}",
      "username": "${aws_rds_cluster.db-cluster.master_username}",
      "password": "${aws_rds_cluster.db-cluster.master_password}",
      "dbname": "mydb",
      "port": "5432"
    }
  EOF
}
/*
data "aws_secretsmanager_secret" "secrets" {
  depends_on = [aws_secretsmanager_secret.db-secret]
  arn        = aws_secretsmanager_secret.db-secret.arn
  }
data "aws_secretsmanager_secret_version" "current_secrets" {
  depends_on = [aws_secretsmanager_secret_version.db-secret-version]
  secret_id = data.aws_secretsmanager_secret.secrets.id
 }
 */
