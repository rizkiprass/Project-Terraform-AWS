//create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = merge(local.common_tags,
    {
      Name = format("%s-%s-VPC", var.Customer, var.environment)
  })
}

//subnet
resource "aws_subnet" "subnet-public-1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.Public_Subnet_AZ1
  availability_zone = format("%sa", var.region)
  tags = merge(local.common_tags,
    {
      Name = format("%s-%s-public-subnet-1a", var.Customer, var.environment)
  })
}

resource "aws_subnet" "subnet-public-1b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.Public_Subnet_AZ2
  availability_zone = format("%sb", var.region)
  tags = merge(local.common_tags, {
    Name = format("%s-%s-public-subnet-1b", var.Customer, var.environment)
  })
}

resource "aws_subnet" "subnet-app-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.App_Subnet_AZ1
  availability_zone = format("%sa", var.region)
  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-app-subnet-1a", var.Customer, var.environment)
  })
}
resource "aws_subnet" "subnet-app-1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.App_Subnet_AZ2
  availability_zone = format("%sb", var.region)
  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-app-subnet-1b", var.Customer, var.environment)
  })
}
resource "aws_subnet" "subnet-data-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.Data_Subnet_AZ1
  availability_zone = format("%sa", var.region)
  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-data-subnet-1a", var.Customer, var.environment)
  })
}

resource "aws_subnet" "subnet-data-1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.Data_Subnet_AZ2
  availability_zone = format("%sb", var.region)
  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-data-subnet-1b", var.Customer, var.environment)
  })
}

//IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, {
    Name = format("%s-%s-igw", var.Customer, var.environment)
  })
}

//EIP
resource "aws_eip" "eip" {
  vpc = true
  tags = merge(local.common_tags, {
    Name = format("%s-%s-EIP", var.Customer, var.environment)
  })
}

# resource "aws_eip" "eip2" {
#   vpc = true
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP2", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-web1" {
#   vpc = true
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP2", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-web2" {
#   vpc = true
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP2", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-web3" {
#   vpc = true
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP2", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-web4" {
#   vpc = true
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP2", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-bastion" {
#   vpc = true
#   instance = aws_instance.bastion.id
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-EIP-bastion", var.Customer, var.environment)
#   })
# }

# resource "aws_eip" "eip-dev" {
#   vpc = true
#   instance = aws_instance.dev.id
#   tags = merge(local.common_tags, {
#     Name = format("%s-EIP-dev", var.Customer)
#   })
# }

//NAT Gateway

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet-public-1a.id
  depends_on = [
  aws_internet_gateway.igw]
  tags = merge(local.common_tags, {
    Name = format("%s-%s-NAT1a", var.Customer, var.environment)
  })
}

# resource "aws_nat_gateway" "natgw1b" {
#   allocation_id = aws_eip.eip2.id
#   subnet_id     = aws_subnet.subnet-public-1b.id
#   depends_on = [
#   aws_internet_gateway.igw]
#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-NAT1b", var.Customer, var.environment)
#   })
# }

//routing table

resource "aws_route_table" "public-rt1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-public-web-RT", var.Customer, var.environment)
  })
}

resource "aws_route_table" "private-rt1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-app-1a-RT", var.Customer, var.environment)
  })
}

# resource "aws_route_table" "private-rt1b" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.natgw1b.id
#   }

#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-private-app-1b-RT", var.Customer, var.environment)
#   })
# }

resource "aws_route_table" "intra-rt1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  //make sure perlu koneksi ke internet ga dari subnet data?

  tags = merge(local.common_tags, {
    Name = format("%s-%s-private-data1a-RT", var.Customer, var.environment)
  })

}

# resource "aws_route_table" "intra-rt1b" {
#   vpc_id = aws_vpc.vpc.id



#   tags = merge(local.common_tags, {
#     Name = format("%s-%s-private-data1b-RT", var.Customer, var.environment)
#   })

# }

//routing table association

resource "aws_route_table_association" "rt-subnet-assoc-public1a" {
  subnet_id      = aws_subnet.subnet-public-1a.id
  route_table_id = aws_route_table.public-rt1a.id
}

resource "aws_route_table_association" "rt-subnet-assoc-public1b" {
  subnet_id      = aws_subnet.subnet-public-1b.id
  route_table_id = aws_route_table.public-rt1a.id
}

resource "aws_route_table_association" "rt-subnet-assoc-private1a" {
  subnet_id      = aws_subnet.subnet-app-1a.id
  route_table_id = aws_route_table.private-rt1a.id
}

resource "aws_route_table_association" "rt-subnet-assoc-private1b" {
  subnet_id      = aws_subnet.subnet-app-1b.id
  route_table_id = aws_route_table.private-rt1a.id
}

resource "aws_route_table_association" "rt-subnet-assoc-intra1a" {
  subnet_id      = aws_subnet.subnet-data-1a.id
  route_table_id = aws_route_table.intra-rt1a.id
}

resource "aws_route_table_association" "rt-subnet-assoc-intra1b" {
  subnet_id      = aws_subnet.subnet-data-1b.id
  route_table_id = aws_route_table.intra-rt1a.id
}