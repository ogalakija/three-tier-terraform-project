resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
  })
}

# Creating Internet Gateway_________________________________________________________________________
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

# Creating  2 Public Subnets_________________________________________________________________________
resource "aws_subnet" "apci_jupiter_public_subnet_AZ_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_AZ_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1b"
  })
}

# Creating  2 Private Subnets_________________________________________________________________________
resource "aws_subnet" "apci_jupiter_private_subnet_AZ_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_private_subnet_AZ_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1b"
  })
}

# Creating  2 Database Subnets_________________________________________________________________________
resource "aws_subnet" "apci_jupiter_db_subnet_AZ_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.database_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-database-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_AZ_1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.database_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-database-subnet-az-1b"
  })
}

# Creating Public Route Table_________________________________________________________________________________________
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
} 

# Creating Route table association____________________________________
resource "aws_route_table_association" "public_subnet_AZ_1a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_AZ_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "public_subnet_AZ_1b" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_AZ_1b.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# Creating an Elastic IP for NAT gateway in AZ 1A
resource "aws_eip" "apci_jupiter_eip_AZ_1A" {
  domain   = "vpc"

    tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az_1a"
  })
}

#Creating a NAT Gateway
resource "aws_nat_gateway" "apci_jupiter_nat_gw_AZ-1A" {
  allocation_id = aws_eip.apci_jupiter_eip_AZ_1A.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_AZ_1a.id

    tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.apci_jupiter_eip_AZ_1A, aws_subnet.apci_jupiter_public_subnet_AZ_1a]
}

# Creating Private Route Table for AZ 1a_________________________________________________________________________________________
resource "aws_route_table" "apci_jupiter_private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_AZ-1A.id
  }
  tags = merge(var.tags, {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt"
  })
} 