
# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "my_vpc"
  }
}

#Create Subnet 1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
}


#Create Subnet 2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#Create Route Table and Attach to Internet Gateway
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Associate Route Table with Subnets
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

#Associate Route Table with Subnets
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

#Create Security Group
resource "aws_security_group" "sg" {
  name        = "webapp-sg"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "WEB-SG"
  }
}
#EC2 Instance
resource "aws_instance" "web1" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "ubuntu-vm"
  user_data              = file("docker.sh")

  tags = {
    Name = "WebServer1Instance"
  }
}
resource "aws_instance" "web2" {
  ami                    = "ami-00d8fc944fb171e29"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "ubuntu-vm"
  user_data              = file("docker.sh")
  tags = {
    Name = "WebServer2Instance"
  }
}

#Create Load Balancer
resource "aws_lb" "my_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  tags = {
    Name = "webapp-lb"
  }
}
#Create Target Group
resource "aws_lb_target_group" "webtg" {
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

#Create target group attachment for web1
resource "aws_lb_target_group_attachment" "web1_attach" {
  target_group_arn = aws_lb_target_group.webtg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

#Create target group attachment for web2
resource "aws_lb_target_group_attachment" "web2_attach" {
  target_group_arn = aws_lb_target_group.webtg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

#Create Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtg.arn
  }

}