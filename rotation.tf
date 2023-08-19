data "aws_partition" "current" {}
data "aws_region" "current" {}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  # make sure that the initial value is saved before setting up rotation, otherwise, it can result in a ResourceNotFoundException: An error occurred (ResourceNotFoundException) when calling the GetSecretValue operation:Secrets Manager can't find the specified secret value for staging label: AWSCURRENT
  secret_id           = aws_secretsmanager_secret_version.db-secret-version.secret_id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.secrets_rotator.outputs.RotationLambdaARN

  rotation_rules {
    automatically_after_days = var.secrets_rotation_interval
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  service_name       = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  security_group_ids = [aws_security_group.vpce_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  //route_table_ids     = aws_route_table.db-pvt-rt[*].id
  subnet_ids        = aws_subnet.db-subnet[*].id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.aws-secrets-manager-vpc.id

  tags = {
    Name = "${local.Owner}-secrets-manager-endpoint"
  }
}

resource "aws_vpc_endpoint_security_group_association" "int-vpce-assoc" {
  vpc_endpoint_id   = aws_vpc_endpoint.secretsmanager.id
  security_group_id = aws_security_group.vpce_security_group.id
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "secrets_rotator" {
  name           = "Rotator-${random_id.id.hex}"
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]
  parameters = {
    functionName        = "LambdaRotator-${random_id.id.hex}"
    endpoint            = "https://secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
    vpcSubnetIds        = join(",", aws_subnet.db-subnet.*.id)
    vpcSecurityGroupIds = aws_security_group.lambda_security_group.id
  }
}

/*
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.aws-secrets-manager-vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.db-subnet[*].id
  security_group_ids  = [aws_security_group.db_sec_grp.id, aws_security_group.int_vpce_sec_grp.id]
  //subnet_ids        = [aws_subnet.db-subnet[0].id]
}

data "aws_serverlessapplicationrepository_application" "rotator" {
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"
  //application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationMultiUser"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotate-stack" {
  name             = "Rotator-${random_id.id.hex}"
  application_id   = data.aws_serverlessapplicationrepository_application.rotator.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.rotator.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.rotator.required_capabilities

  parameters = {
    endpoint            = "https://secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
    functionName        = "LambdaRotator-${random_id.id.hex}"
    vpcSubnetIds        = aws_subnet.db-subnet[0].id
    //vpcSubnetIds      = aws_subnet.db-subnet[*].id
    vpcSecurityGroupIds = aws_security_group.db_sec_grp.id
  }
}
*/
