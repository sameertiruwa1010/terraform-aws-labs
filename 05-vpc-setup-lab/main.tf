#############################################
# PROVIDER
#############################################

provider "aws" {
  region = "ap-south-1"
}

#############################################
# VPC
#############################################

resource "aws_vpc" "sameer_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "sameer-vpc"
  }
}

#############################################
# SUBNETS
#############################################

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.sameer_vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sameer-pub-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.sameer_vpc.id
  cidr_block              = "10.1.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sameer-pub-2"
  }
}

# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.sameer_vpc.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "sameer-prvt-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.sameer_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "sameer-prvt-2"
  }
}

#############################################
# INTERNET GATEWAY
#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sameer_vpc.id

  tags = {
    Name = "sameer-igw"
  }
}

#############################################
# ROUTE TABLES
#############################################

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sameer_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "sameer-pub-route"
  }
}

# Private Route Table (No Internet Route)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.sameer_vpc.id

  tags = {
    Name = "sameer-prvt-route"
  }
}

#############################################
# ROUTE TABLE ASSOCIATIONS
#############################################

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

#############################################
# SECURITY GROUP (PUBLIC EC2)
#############################################

resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.sameer_vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

#############################################
# AMAZON LINUX 2023 AMI (Dynamic)
#############################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

#############################################
# EC2 INSTANCES
#############################################

# Public EC2
resource "aws_instance" "public_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  key_name               = "root-sameer"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "public-ec2"
  }
}

# Private EC2
resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  key_name               = "root-sameer"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "private-ec2"
  }
}

#############################################
# OUTPUT
#############################################

output "public_ec2_ip" {
  value = aws_instance.public_ec2.public_ip
}
