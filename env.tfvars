##################
# General Values #
##################
aws_region  = "us-east-2"
aws_profile = "tf-admin"
//role_arn                  = "arn:aws:iam::502433561161:role/374278-TerraformRole"
//session_name              = "tf_sts_session"
rsa-bits       = 4096
key-pair-name  = "374278-awssecretsmanager"
aws_account_id = "502433561161"
vpc_cidr       = "10.20.0.0/16"
//az_count              = 3
byte_length           = 4
bastion_instance_type = "t3.large"
bastion-root-vol-size = 80
bastion-vol-type      = "gp3"
db_instance_type      = "db.serverless"
db_engine_version     = "14.3"
db_engine_mode        = "provisioned"
//PUBLIC_KEY                = "374278-secretsmanagerdemo"
secrets_rotation_interval = 1
//db_allocated_storage = 64
