resource "aws_vpc" "fawaz-tfe-es-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "name" = "fawaz-tfe-es-vpc"
  }
}

resource "aws_subnet" "fawaz-tfe-es-pub-sub" {
  count             = var.subnet_count
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  vpc_id            = aws_vpc.fawaz-tfe-es-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  tags = {
    "name" = "fawaz-tfe-es-pub-sub"
  }
}

resource "aws_subnet" "fawaz-tfe-es-pri-sub" {
  count             = var.subnet_count
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  vpc_id            = aws_vpc.fawaz-tfe-es-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 3 + count.index)
  tags = {
    "name" = "fawaz-tfe-es-pri-sub"
  }
}

resource "aws_internet_gateway" "fawaz-tfe-es-igw" {
  vpc_id = aws_vpc.fawaz-tfe-es-vpc.id

  tags = {
    Name = "fawaz-tfe-es-igw"
  }
}

resource "aws_route_table" "fawaz-tfe-es-pub-rt" {
  vpc_id = aws_vpc.fawaz-tfe-es-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fawaz-tfe-es-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.fawaz-tfe-es-igw.id
  }

  tags = {
    Name = "fawaz-tfe-es-pub-rt"
  }
}

resource "aws_route_table" "fawaz-tfe-es-pri-rt" {
  vpc_id = aws_vpc.fawaz-tfe-es-vpc.id

  tags = {
    Name = "fawaz-tfe-es-pri-rt"
  }
}

resource "aws_route_table_association" "fawaz-tfe-es-pub-rt-asc" {
  count          = 3
  subnet_id      = element(aws_subnet.fawaz-tfe-es-pub-sub[*].id, count.index)
  route_table_id = aws_route_table.fawaz-tfe-es-pub-rt.id
}

resource "aws_route_table_association" "fawaz-tfe-es-pri-rt-asc" {
  count          = 3
  subnet_id      = element(aws_subnet.fawaz-tfe-es-pri-sub[*].id, count.index)
  route_table_id = aws_route_table.fawaz-tfe-es-pri-rt.id
}