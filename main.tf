resource "aws_vpc" "wanneski" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.wanneski.id
  cidr_block              = "10.123.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.wanneski.id
  cidr_block              = "10.123.10.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub3" {
  vpc_id                  = aws_vpc.wanneski.id
  cidr_block              = "10.123.20.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.wanneski.id

  tags = {
    Name = "igwdev"
  }
}

resource "aws_route_table" "wanneski" {
  vpc_id = aws_vpc.wanneski.id

}

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_route_table.wanneski.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.wanneski.id
}
resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.wanneski.id
}

resource "aws_route_table_association" "pub3" {
  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.wanneski.id
}

resource "aws_instance" "dan" {
  ami                    = data.aws_ami.ubuntu.id
  count                  = 3
  instance_type          = "t2.micro"
  key_name               = "dankey"
  vpc_security_group_ids = [aws_security_group.MySg.id]
  subnet_id              = aws_subnet.pub1.id
  user_data              = "${file("dan.tpl")}"

  tags = {
    Name = "instance ${count.index}"
  }

  #provisioner "remote-exec" {
    #connection {
    #type = "ssh"
   # user = "ubuntu"
   # host = self.public_ip
  #  private_key = file("/home/vagrant/danudelekey1.pem")

 # }
  #inline = ["echo 'wait for ssh'"]
 #}

  # provisioner "local-exec" {
  #  command = "echo '${self.public_ip}' >> ./host-inventory"
 # }
#}

#resource "null_resource" "ansible-playbook" {
  #provisioner "local-exec" {
   # command = "ansible-playbook -i host-inventory --private ${var.ssh_key}.pem Apache.yml"
  #}

  #depends_on = [aws_instance.dan]

}

resource "local_file" "Ip_address" {
  filename = "./host-inventory"
  content  = <<EOT
 ${aws_instance.dan[count.index].public_ip}
 ${aws_instance.dan[count.index].public_ip}
 ${aws_instance.dan[count.index].public_ip}
  EOT
  count    = length(aws_instance.dan)

}

resource "aws_security_group" "MySg" {
  name        = "My security Group"
  description = "Allow Http and ssh inbound traffic"
  vpc_id      = aws_vpc.wanneski.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "danlb" {
  name               = "danlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.MySg.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id, aws_subnet.pub3.id]
}
resource "aws_lb_target_group" "alb-dan" {
  name        = "danalb"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.wanneski.id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
    healthy_threshold   = 5

  }
}


resource "aws_lb_target_group_attachment" "alb-dan" {
  count            = length(aws_instance.dan)
  target_group_arn = aws_lb_target_group.alb-dan.arn
  target_id        = aws_instance.dan[count.index].id
  port             = 80
}

resource "aws_lb_listener" "dan" {
  load_balancer_arn = aws_lb.danlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-dan.arn
  }
}

