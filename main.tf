# ----------------------------------------------------------
# Creating Vpc
# ----------------------------------------------------------

resource "aws_vpc" "vpc" {
    
  cidr_block           =  var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   =  true
  enable_dns_hostnames =  true 
  tags = {
    Name = "${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Igw
# ----------------------------------------------------------

resource "aws_internet_gateway" "igw" {
    
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}


# ----------------------------------------------------------
# Creating Public Subnet1
# ----------------------------------------------------------

resource "aws_subnet" "public1" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,0)
  map_public_ip_on_launch = true
  availability_zone  = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "public1-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Public Subnet2
# ----------------------------------------------------------

resource "aws_subnet" "public2" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,1)
  map_public_ip_on_launch = true
  availability_zone  = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "public2-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}


# ----------------------------------------------------------
# Creating Public Subnet3
# ----------------------------------------------------------

resource "aws_subnet" "public3" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,2)
  map_public_ip_on_launch = true
  availability_zone  = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "public3-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Private Subnet1
# ----------------------------------------------------------

resource "aws_subnet" "private1" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,3)
  map_public_ip_on_launch = false
  availability_zone  = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "private1-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Private Subnet2
# ----------------------------------------------------------

resource "aws_subnet" "private2" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,4)
  map_public_ip_on_launch = false
  availability_zone  = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "private2-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Private Subnet3
# ----------------------------------------------------------

resource "aws_subnet" "private3" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,5)
  map_public_ip_on_launch = false
  availability_zone  = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "private3-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Elastic Ip
# ----------------------------------------------------------


resource "aws_eip" "ngw" {
  vpc      = true
  tags = {
    Name = "nat-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}

# ----------------------------------------------------------
# Creating Nat gateway
# ----------------------------------------------------------

resource "aws_nat_gateway" "ngw" {
    
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "${var.project}-${var.env}"
    project = var.project
    env = var.env
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


# ----------------------------------------------------------
# Creating Public Route Table
# ----------------------------------------------------------


resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}


# ----------------------------------------------------------
# Creating Private Route Table
# ----------------------------------------------------------


resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-${var.project}-${var.env}"
    project = var.project
    env = var.env
  }
}


# ----------------------------------------------------------
# Public Route table Association
# ----------------------------------------------------------

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}


# ----------------------------------------------------------
# Private Route table Association
# ----------------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
