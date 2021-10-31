#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MASTER-vpc"
  }

}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_master.id
  tags = {
    "Name" = "igw"
  }
}


#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_public_A" {
  availability_zone       = element(data.aws_availability_zones.azs.names, 1) #us-east-1a
  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PublicSubnet A"
  }
}


#Create subnet #2  in us-east-1
resource "aws_subnet" "subnet_public_B" {
  vpc_id                  = aws_vpc.vpc_master.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 2) #us-east-1b
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PublicSubnet B"
  }
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_private_A" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1) #us-east-1a
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.12.0/24"
  tags = {
    "Name" = "PrivateSubnet A"
  }
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_private_B" {
  availability_zone = element(data.aws_availability_zones.azs.names, 2) #us-east-1a
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.22.0/24"
  tags = {
    "Name" = "PrivateSubnet B"
  }
}

resource "aws_subnet" "subnet_dbsubnet_A" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1) #us-east-1a
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.13.0/24"
  tags = {
    "Name" = "DBSubnet A"
  }
}

resource "aws_subnet" "subnet_dbsubnet_B" {
  availability_zone = element(data.aws_availability_zones.azs.names, 2) #us-east-1a
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.23.0/24"
  tags = {
    "Name" = "DBSubnet B"
  }
}


#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  # lifecycle {
  #   ignore_changes = all
  # }
  tags = {
    Name = "Master-Region-RT"
  }
}

resource "aws_route_table" "private_subnet_route_A" {
  vpc_id = aws_vpc.vpc_master.id
  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat_A.id
  }
  tags = {
    Name = "Private-Subnet-RT-A"
  }
}

resource "aws_route_table" "private_subnet_route_B" {
  vpc_id = aws_vpc.vpc_master.id
  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat_B.id
  }
  tags = {
    Name = "Private-Subnet-RT-B"
  }
}

resource "aws_route_table" "db_subnet_route" {
  vpc_id = aws_vpc.vpc_master.id

  tags = {
    Name = "DB-Subnet-RT"
  }
}

resource "aws_route_table_association" "db_subnet_to_db_RT_A" {
  subnet_id      = aws_subnet.subnet_dbsubnet_A.id
  route_table_id = aws_route_table.db_subnet_route.id
}

resource "aws_route_table_association" "db_subnet_to_db_RT_B" {
  subnet_id      = aws_subnet.subnet_dbsubnet_B.id
  route_table_id = aws_route_table.db_subnet_route.id
}

resource "aws_route_table_association" "private_subnet_to_private_RT_A" {
  subnet_id      = aws_subnet.subnet_private_A.id
  route_table_id = aws_route_table.private_subnet_route_A.id
}

resource "aws_route_table_association" "private_subnet_to_private_RT_B" {
  subnet_id      = aws_subnet.subnet_private_B.id
  route_table_id = aws_route_table.private_subnet_route_B.id
}


#Overwrite default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_eip" "nat_gateway_A" {
  vpc = true
}

resource "aws_eip" "nat_gateway_B" {
  vpc = true
}

resource "aws_nat_gateway" "public_nat_A" {
  allocation_id = aws_eip.nat_gateway_A.id
  subnet_id     = aws_subnet.subnet_public_A.id

  tags = {
    Name = "Publica NAT A"
  }
}

resource "aws_nat_gateway" "public_nat_B" {
  allocation_id = aws_eip.nat_gateway_B.id
  subnet_id     = aws_subnet.subnet_public_B.id

  tags = {
    Name = "Publica NAT B"
  }
}




















































































