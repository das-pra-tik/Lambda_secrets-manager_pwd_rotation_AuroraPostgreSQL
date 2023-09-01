resource "aws_security_group" "bastion_sec_grp" {
  name   = "${local.Owner}-Bastion_sg"
  vpc_id = aws_vpc.aws-secrets-manager-vpc.id
  tags = {
    Name = "${local.Owner}-Bastion_sg"
  }
  /*
  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  */
  ingress {
    from_port   = 3389
    to_port     = 3389
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    self = false
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpce_security_group" {
  name   = "${local.Owner}-vpc_endpoint_security_group"
  vpc_id = aws_vpc.aws-secrets-manager-vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = false
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = false
  }
  tags = {
    Name = "${local.Owner}-vpc_endpoint_security_group"
  }
}

resource "aws_security_group" "lambda_security_group" {
  name   = "${local.Owner}-rotator_lambda_security_group"
  vpc_id = aws_vpc.aws-secrets-manager-vpc.id

  tags = {
    Name = "${local.Owner}-rotator_lambda_security_group"
  }
}

resource "aws_security_group_rule" "lambda_security_group_egress_rule1" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.aws-secrets-manager-vpc.cidr_block]
  security_group_id = aws_security_group.lambda_security_group.id
}

resource "aws_security_group_rule" "lambda_security_group_egress_rule2" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.aws-secrets-manager-vpc.cidr_block]
  security_group_id = aws_security_group.lambda_security_group.id
}

resource "aws_security_group_rule" "lambda_security_group_ingress_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.aws-secrets-manager-vpc.cidr_block]
  security_group_id = aws_security_group.lambda_security_group.id
}

resource "aws_security_group" "db_sec_grp" {
  name   = "${local.Owner}-PostgreSQL_sg"
  vpc_id = aws_vpc.aws-secrets-manager-vpc.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sec_grp.id]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion_sec_grp.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.aws-secrets-manager-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.Owner}-PostgreSQL_sg"
  }
}

/*
resource "aws_security_group" "int_vpce_sec_grp" {
  name   = "Interface_vpce_sg"
  vpc_id = aws_vpc.aws-secrets-manager-vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    //cidr_blocks = [aws_vpc.aws-secrets-manager-vpc.cidr_block]
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/
