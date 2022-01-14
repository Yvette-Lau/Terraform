# 1. create EC2 instance key pairs on AWS console

# 2. create a vpc

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 3. create internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-GW"
  }
}

# 4. create Custom Route table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
      #cidr_block = "10.0.1.0/24"
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id

    }
  route {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = aws_internet_gateway.gw.id
    }
  tags = {
    Name = "prod-route-Table"
  }
}

# 5. create a Subnet

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

# 6 Associate subnet with Route Table
resource "aws_route_table_association" "routeTable-subnet-Associate" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

# create secruity Group to allow port 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress = [
    {
      description      = "HTTPS to VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false

    },
    {
      description      = "HTTP to VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false

    },
    {
      description      = "SSH to VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false

    }
  ]
  egress = [
    {
      description      = "allow all outgoing traffic from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "allow_web_traffic"
  }
}

# 7. create network interface (NIC)
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.public-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8 create elastic IP and associate with NIC, EIP depend on the IGW, check the document
resource "aws_eip" "lb" {
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = aws_network_interface.web-server-nic.private_ip
  #associate_with_private_ip = "10.0.1.50"
  vpc      = true
  depends_on = [aws_internet_gateway.gw]
}

# 9 create a server and install/enable apache2
resource "aws_instance" "web-server" {
  ami = "ami-09e67e426f25ce0d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "Yvette-EC2"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
              #!/bin/sh
              sudo apt-get update -y
              sudo apt-get install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo Hello world! > /var/www/html/index.html'
              EOF
  tags = {
    Name = "Web-server"
  }
}