resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_vpc
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_subnet1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_subnet2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet_1.id

}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet_2.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "Web-sg"
  }

}

resource "aws_s3_bucket" "mybucket" {
  bucket = "test-bucket-demo-sat7654"

}

resource "aws_instance" "webserver1" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.subnet_1.id
  user_data_base64       = base64encode(file("userdata.sh"))

}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.subnet_2.id
  user_data_base64       = base64encode(file("userdata1.sh"))

}

resource "aws_alb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "web"
  }

}

resource "aws_lb_target_group" "tg" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_id        = aws_instance.webserver1.id
  target_group_arn = aws_lb_target_group.tg.arn
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_id        = aws_instance.webserver2.id
  target_group_arn = aws_lb_target_group.tg.arn
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}
output "loadbalancerdns" {
  value = aws_alb.myalb.dns_name
}