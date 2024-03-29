//Server Prod-App
resource "aws_instance" "prod-app" {
  ami                         = var.ami-ubuntu
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  key_name                    = "key-sandbox"
  subnet_id                   = aws_subnet.subnet-app-1a.id
  iam_instance_profile        = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [aws_security_group.Prod-App-sg.id]
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-%s-app-ebs", var.Customer, var.environment)
    })
  }

  tags = merge(local.common_tags, {
    Name                = format("%s-%s-App-rpras", var.Customer, var.environment),
    start-stop-schedule = false,
    OS                  = "Ubuntu",
    Backup              = "DailyBackup" # TODO: Set Backup Rules
  })
}

//Server Dev-App
resource "aws_instance" "dev-app" {
  ami                         = var.ami-ubuntu
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  key_name                    = "key-sandbox"
  subnet_id                   = aws_subnet.subnet-app-1a.id
  iam_instance_profile        = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [aws_security_group.Dev-App-sg.id]
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-dev-app", var.Customer)
    })
  }

  tags = merge(local.common_tags_dev, {
    Name                = format("%s-dev-App-rpras", var.Customer),
    start-stop-schedule = false,
    OS                  = "Ubuntu",
    Backup              = "DailyBackup" # TODO: Set Backup Rules
  })
}

//Server Prod-Data
resource "aws_instance" "Prod-Data" {
  ami                         = var.ami-ubuntu
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  key_name                    = "key-sandbox"
  subnet_id                   = aws_subnet.subnet-data-1a.id
  iam_instance_profile        = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [aws_security_group.Prod-Data-sg.id]
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-%s-data", var.Customer, var.environment)
    })
  }

  tags = merge(local.common_tags, {
    Name                = format("%s-%s-Data-rpras", var.Customer, var.environment),
    start-stop-schedule = false,
    OS                  = "Ubuntu",
    Backup              = "DailyBackup" # TODO: Set Backup Rules
  })
}

###############
# OpenVPN + NAT Instance
##############
resource "aws_eip" "openvpn-nat" {
  instance = aws_instance.openvpn.id
  tags = merge(local.common_tags, {
    Name = format("%s-%s-openvpn-eip", var.project, var.environment)
  })
}
output "openvpn-eip" {
  value = aws_eip.openvpn-nat.public_ip
}
resource "aws_instance" "openvpn" {
  ami                  = var.ami-ubuntu
  instance_type        = "t2.micro"
  key_name             = "key-sandbox"
  subnet_id            = aws_subnet.subnet-public-1a.id
  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [
  aws_security_group.openvpn-sg.id]
  source_dest_check = false
  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-%s-openvpn-ebs", var.project, var.environment),
    })
  }
  tags = merge(local.common_tags, {
    Name                = format("%s-%s-openvpn-rpras", var.project, var.environment),
    start-stop-schedule = false,
    Backup              = "MonthlyBackup"
  })
}

