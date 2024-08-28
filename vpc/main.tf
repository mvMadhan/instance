resource "aws_vpc" "my_vpc" {
cidr_block ="10.0.0.0/16"

tags = {
Name = "myvcp"
}
}

resource "aws_subnet" "public"{
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = true
availability_zone = "us-east-1a"

tags ={
Name ="public_subnet"
}
}

resource "aws_subnet" "private"{
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1b"
map_public_ip_on_launch = false

tags ={
Name = "private_subnet"
}
}

resource "aws_internet_gateway" "ig" {
vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "rt_p"{
vpc_id = aws_vpc.my_vpc.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
}

resource "aws_route_table_association" "pb_rtas" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt_p.id
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
 }
}

resource "aws_route_table" "rt_pv"{
vpc_id =aws_vpc.my_vpc.id

route {
cidr_block ="0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id

}
}

resource "aws_route_table_association" "pv_rtas" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt_pv.id
}

resource "aws_security_group" "sg_p"{

vpc_id = aws_vpc.my_vpc.id

ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


}

resource "aws_security_group" "sg_pv"{

vpc_id =aws_vpc.my_vpc.id

ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [aws_subnet.public.cidr_block]
}

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}


resource "aws_instance" "example1"{
ami ="ami-066784287e358dad1"
key_name = "sk1"
subnet_id = aws_subnet.public.id
instance_type ="t2.micro"
vpc_security_group_ids = [aws_security_group.sg_p.id]

user_data = base64encode(file("userdata.sh"))

tags = {
Name = "public-server-1"
}
}

resource "aws_instance" "example2" {
ami = "ami-066784287e358dad1"
instance_type = "t2.micro"
subnet_id = aws_subnet.private.id
vpc_security_group_ids = [aws_security_group.sg_pv.id]
key_name ="sk1"


tags ={
Name ="private-server-1"
}
}
