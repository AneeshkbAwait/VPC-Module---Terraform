# VPC-Module-Terraform

A Terraform module is a set of Terraform configuration files in a single directory. Even a simple configuration consisting of a single directory with one or more .tf files is a module.

Here, we have an example for a VPC module. Using this module, We can remove the overhead of rewriting the code for VPC creation each time when building infrastructure using Terraform. This VPC module can be used in situations where we want to create a VPC while infra building.

### variables.tf

Required Module variables are defined in variables.tf and they are using default values set by me. These variable values shall be overrided when we are calling the modules in a project.

```
variable "vpc_cidr" {
    
  default = "172.16.0.0/16"
}

variable "project" {
    
  default = "pjt_example"
}

variable "env" {
    
  default = "env_example"
}
```

### output.tf

Whatever output values we defined at the output.tf shall be returned to the original project whenever they needed. Here, I have created output for Public and Private subnets and the vpc_id, so that they shall be called and used at the original project.

```
output "vpc_id" {
    
  value = aws_vpc.vpc.id
}

output "public1_subnet_id" {
    
  value = aws_subnet.public1.id
}

output "public2_subnet_id" {
    
  value = aws_subnet.public2.id
}

output "public3_subnet_id" {
    
  value = aws_subnet.public3.id
}

output "private1_subnet_id" {
    
  value = aws_subnet.private1.id
}
output "private2_subnet_id" {
    
  value = aws_subnet.private2.id
}

output "private3_subnet_id" {
    
  value = aws_subnet.private3.id
}
```

### datasource.tf

The available zones at the current region will be fetched using the "aws_availability_zones" data source. For example, If we are targetting the Mumbai region, then we will have ap-south-1a, ap-south-1b, and ap-south-1c availabilty zones.
```
data "aws_availability_zones" "az" {
  state = "available"
}
```

### main.tf

VPC Creation. We will create the following resources which should be required for making a VPC intercative;
1. A Private and Public subnets for each availabilty zone.
2. Elastic IP for NAT gateway.
3. NAT Gateway for having internet access to private subnets.
4. Route tables for private and public subnets.
5. Route table association to these public and private subnets.

```
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
```

## Calling the Module

You can import the module in any of your project like below;

module "vpc" {
  source = "/var/terraform/modules/vpc/"
  vpc_cidr = var.project_vpc_cidr
  project  = var.project_name
  env      = var.project_environment
}

    source - Location of the Module
    vpc_cidr - Passing the VPC CIDR to the Module as a Variable
    project - Passing the Project Name to the Module as a Variable
    env - Passing the Project Environment to the Module as Variable
    
I hope this is clear to everone, and you should be ready to go with reusing this module in your projects!!!!
