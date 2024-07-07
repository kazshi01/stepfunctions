data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["default-vpc"]
  }
}

data "aws_subnet" "default_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["default-a"]
  }
  vpc_id = data.aws_vpc.default.id
}

resource "aws_eip" "nat_eip" {}

data "aws_route_table" "private_route_table" {
  filter {
    name   = "tag:Name"
    values = ["default-private-route"]
  }
  vpc_id = data.aws_vpc.default.id
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = data.aws_subnet.default_public_subnet.id
  allocation_id = aws_eip.nat_eip.id
}

resource "aws_route" "private_route" {
  route_table_id         = data.aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
