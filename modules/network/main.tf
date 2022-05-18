# Get region
data "aws_region" "current" {}

locals {
  subnets = {
    db = [
      "10.0.1.0/24",
      "10.0.2.0/24",
    ]
    app = [
      "10.0.3.0/24",
      "10.0.4.0/24",
    ]
    midd = [
      "10.0.5.0/24",
      "10.0.6.0/24",
    ]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main VPC"
  }
}

output "vpc_main_id" {
  value = aws_vpc.main.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "db_subnets" {
  count = length(local.subnets.db)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnets.db[count.index]
  availability_zone = count.index == 0 ? "${data.aws_region.current.name}a" : "${data.aws_region.current.name}b"

  tags = {
    Name = "DbSubnet0${count.index + 1}"
  }
}

output "db_subnets_id" {
  value = aws_subnet.db_subnets[*].id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Db Public route table"
  }
}

resource "aws_route_table_association" "db_associate" {
  for_each       = toset(aws_subnet.db_subnets[*].id)
  subnet_id      = each.value
  route_table_id = aws_route_table.db.id
}

resource "aws_subnet" "app_subnets" {
  count = length(local.subnets.app)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnets.app[count.index]
  availability_zone = count.index == 0 ? "${data.aws_region.current.name}a" : "${data.aws_region.current.name}b"

  tags = {
    Name = "AppSubnet0${count.index + 1}"
  }
}

output "app_subnets_id" {
  value = aws_subnet.app_subnets[*].id
}

resource "aws_subnet" "midd_subnets" {
  count = length(local.subnets.midd)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnets.midd[count.index]
  availability_zone = count.index == 0 ? "${data.aws_region.current.name}a" : "${data.aws_region.current.name}b"

  tags = {
    Name = "MiddlewareSubnet0${count.index + 1}"
  }
}

output "midd_subnets_id" {
  value = aws_subnet.midd_subnets[*].id
}

# Find my public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# RDS
resource "aws_security_group" "rds" {
  name        = "RDS SG"
  description = "SG for the RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Inbound permit VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Permit public single IP connection"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    description = "Outbound permit all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS SG"
  }
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}