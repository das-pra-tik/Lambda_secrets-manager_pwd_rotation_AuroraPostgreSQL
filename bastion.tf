/*
locals {
  Owner = "374278"
}
*/
data "aws_vpc" "bastion_vpc" {
  depends_on = [aws_vpc.aws-secrets-manager-vpc]
  id         = aws_vpc.aws-secrets-manager-vpc.id
  tags = {
    Name = "${local.Owner}-SecretsManagerVPC"
  }
}

data "aws_subnet_ids" "bastion_subnets" {
  depends_on = [aws_vpc.aws-secrets-manager-vpc, aws_subnet.Public-subnet]
  vpc_id     = data.aws_vpc.bastion_vpc.id
  tags = {
    Tier = "${local.Owner}-Public"
  }
}
/*
# Get latest Amazon Linux 2 AMI
data "aws_ami" "amzlinux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
*/
# Get latest Windows Server 2019 AMI
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "random_id" "index" {
  byte_length = 2
}

locals {
  subnet_ids_list         = tolist(data.aws_subnet_ids.bastion_subnets.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnet_ids.bastion_subnets.ids)
  bastion_subnet_id       = local.subnet_ids_list[local.subnet_ids_random_index]
}

resource "aws_instance" "bastion" {
  //source_dest_check           = "true"
  //user_data                   = ""
  //subnet_id                   = var.instance_subnet_ids[random_integer.random_int.seed]
  //availability_zone           = data.aws_availability_zones.az_bastion.names[random_integer.random_int.seed]
  //ami                         = var.bastion-os == false ? var.linux-ami : var.windows-ami
  //key_name                    = var.PUBLIC_KEY
  ami                         = data.aws_ami.windows-2019.id
  instance_type               = var.bastion_instance_type
  key_name                    = var.key-pair-name
  subnet_id                   = local.bastion_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sec_grp.id]
  disable_api_termination     = "false"
  associate_public_ip_address = "true"
  tenancy                     = "default"
  ebs_optimized               = "false"
  lifecycle {
    ignore_changes = [subnet_id]
  }
  tags = {
    Name = "${local.Owner}-BastionHost"
  }

  # root disk
  root_block_device {
    volume_type           = var.bastion-vol-type
    volume_size           = var.bastion-root-vol-size
    delete_on_termination = "true"
    encrypted             = "true"
    //kms_key_id          = var.kms-key-ids[count.index]
  }
}
/*
resource "null_resource" "remote-script-execute" {
 depends_on = [aws_instance.bastion]
 connection {
   type        = "ssh"
   host        = aws_instance.bastion.public_ip
   user        = var.USERNAME
   private_key = file(var.PRIVATE_KEY)
 }
 provisioner "local-exec" {
   command = "chmod 400 ${var.PRIVATE_KEY}"
 }
 provisioner "file" {
   source      = "Lipper-L3-Dev.pem"
   destination = "/home/ec2-user/Lipper-L3-Dev.pem"
 }

 provisioner "remote-exec" {
   inline = [
     "cd /home/ec2-user/",
     "sudo chmod 400 Lipper-L3-Dev.pem",
   ]
 }
 */
