output "bastion-public-ip" {
  value = aws_instance.bastion.public_ip
}
output "db-cluster-endpoint" {
  value = aws_rds_cluster.db-cluster.id
}
output "db-cluster-endpoint-arn" {
  value = aws_rds_cluster.db-cluster.arn
}
output "secrets-name" {
  value = aws_secretsmanager_secret.db-secret.name
}
output "secrets-version-id" {
  value = aws_secretsmanager_secret_version.db-secret-version.version_id
}
output "secrets-ARN" {
  value = aws_secretsmanager_secret_version.db-secret-version.arn
}
output "secret-hash" {
  value = jsondecode(nonsensitive(aws_secretsmanager_secret_version.db-secret-version.secret_string))
}
