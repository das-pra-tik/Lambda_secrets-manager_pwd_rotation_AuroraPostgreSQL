locals {
  Owner = "374278"
}
data "aws_availability_zones" "available_az" {
  state = "available"
}
# Create non-default VPC
resource "aws_vpc" "aws-secrets-manager-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${local.Owner}-SecretsManagerVPC"
  }
}

# Create non-default Internet Gateway
resource "aws_internet_gateway" "aws-secrets-manager-igw" {
  depends_on = [aws_vpc.aws-secrets-manager-vpc]
  vpc_id     = aws_vpc.aws-secrets-manager-vpc.id
  tags = {
    Name = "${local.Owner}-SecretsManagerIGW"
  }
}

resource "aws_subnet" "Public-subnet" {
  depends_on              = [aws_vpc.aws-secrets-manager-vpc]
  count                   = length(data.aws_availability_zones.available_az.names)
  vpc_id                  = aws_vpc.aws-secrets-manager-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws-secrets-manager-vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_az.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "SecretsManager-PublicSubnet${count.index + 1}"
    Tier = "${local.Owner}-Public"
  }
}

resource "aws_subnet" "db-subnet" {
  depends_on              = [aws_vpc.aws-secrets-manager-vpc]
  count                   = length(data.aws_availability_zones.available_az.names)
  vpc_id                  = aws_vpc.aws-secrets-manager-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws-secrets-manager-vpc.cidr_block, 8, (count.index + length(data.aws_availability_zones.available_az.names)))
  availability_zone       = data.aws_availability_zones.available_az.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Secrets-Manager-DB-subnet${count.index + 1}"
    Tier = "${local.Owner}-DB"
  }
}

resource "aws_route_table" "Public-rt" {
  depends_on = [aws_subnet.Public-subnet]
  vpc_id     = aws_vpc.aws-secrets-manager-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-secrets-manager-igw.id
  }
  tags = {
    Name = "${local.Owner}-SecretsManager-Public-RT"
  }
}

resource "aws_route_table_association" "frontend-rt-association" {
  depends_on     = [aws_subnet.Public-subnet, aws_route_table.Public-rt]
  count          = length(data.aws_availability_zones.available_az.names)
  subnet_id      = element(aws_subnet.Public-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.Public-rt.*.id, count.index)
}

resource "aws_route_table" "db-pvt-rt" {
  depends_on = [aws_subnet.db-subnet]
  vpc_id     = aws_vpc.aws-secrets-manager-vpc.id
  tags = {
    Name = "${local.Owner}-SecretsManager-DB-RT"
  }
}

resource "aws_route_table_association" "db-pvt-rt-association" {
  depends_on     = [aws_subnet.db-subnet, aws_route_table.db-pvt-rt]
  count          = length(data.aws_availability_zones.available_az.names)
  subnet_id      = element(aws_subnet.db-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.db-pvt-rt.*.id, count.index)
}
