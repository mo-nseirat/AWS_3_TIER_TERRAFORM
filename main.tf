
resource "aws_vpc" "KiQ_Project" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "KiQ_Project_VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.KiQ_Project.id

  tags = {
    Name = "KiQ_IGW"
  }
}


resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block =  var.public_subnets[0]
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block = var.public_subnets[1]
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block = var.private_subnets[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block = var.private_subnets[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private2"
  }
}

resource "aws_subnet" "private_rds1" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block = var.privaterds_subnets[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_rds1"
  }
}

resource "aws_subnet" "private_rds2" {
  vpc_id     = aws_vpc.KiQ_Project.id
  cidr_block = var.privaterds_subnets[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_rds2"
  }
}


resource "aws_eip" "ng1" {
  
  domain   = "vpc"
}

resource "aws_eip" "ng2" {
  
  domain   = "vpc"
}


resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.ng1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "NAT gw1"
  }


  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.ng2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "NAT gw2"
  }


  depends_on = [aws_internet_gateway.gw]
}



resource "aws_route_table" "Public_rt" {
  vpc_id = aws_vpc.KiQ_Project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public_rt"
  }
}

resource "aws_route_table" "Private_rt1" {
  vpc_id = aws_vpc.KiQ_Project.id

  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = "Private_rt1"
  }

}

resource "aws_route_table" "Private_rt2" {
  vpc_id = aws_vpc.KiQ_Project.id

  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "Private_rt2"
  }

}


resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.Public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.Public_rt.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.Private_rt1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.Private_rt2.id
}

resource "aws_route_table_association" "private_rds1" {
  subnet_id      = aws_subnet.private_rds1.id
  route_table_id = aws_route_table.Private_rt1.id
}

resource "aws_route_table_association" "private_rds2" {
  subnet_id      = aws_subnet.private_rds2.id
  route_table_id = aws_route_table.Private_rt2.id
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.KiQ_Project.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "ALB-SG"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   ="bastion_sg"
  vpc_id = aws_vpc.KiQ_Project.id

 ingress {
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
    Name = "Bastion-SG"
  }

}


resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.KiQ_Project.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-Server-SG"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.KiQ_Project.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-SG"
  }
}

resource "aws_key_pair" "Web_Key_Pair" {
  key_name   = "Web_Key_Pair"
  public_key = file("C:/Users/moham/.ssh/kiq_key.pub")
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.Web_Key_Pair.key_name
  
  tags = {
    Name = "bastion_host"
  }
}


resource "aws_instance" "web1" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = aws_key_pair.Web_Key_Pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  
  tags = {
    Name = "Web-Server-1"
  }
}


resource "aws_instance" "web2" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = aws_key_pair.Web_Key_Pair.key_name
   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Web-Server-2"
  }
}

resource "aws_lb" "KiQ-ALB" {
  name               = "KiQ-ALB"
  internal           = false        
  load_balancer_type = "application"      
  security_groups    = [aws_security_group.alb_sg.id]      
  subnets            = [aws_subnet.public1.id , aws_subnet.public2.id]   

  tags = {
    Name = "KiQ-ALB"
  }
}

resource "aws_lb_target_group" "blue_tg" {
  name     = "blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.KiQ_Project.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "Blue-TG"
  }
}


resource "aws_lb_target_group" "green_tg" {
  name     = "green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.KiQ_Project.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "Green-TG"
  }
}


resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = aws_lb_target_group.green_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.KiQ-ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue_tg.arn
        weight = 0 
      }
      target_group {
        arn    = aws_lb_target_group.green_tg.arn
        weight = 100   
      }
    }
  }
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private_rds1.id, aws_subnet.private_rds2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "KiQ_db" {
  allocated_storage    = 10
  db_name              = "KiQ_db"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az = false
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

resource "aws_s3_bucket" "KiQ_s3_bucket" {
  bucket = "kiqnseirats3bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_route53_zone" "KiQ_DN" {
  name = "kiqtrainingcenter.ink"
}

resource "aws_route53_zone" "KiQ_private_DN" {
  name = "kiqtrainingcenter.ink"
  vpc {
    vpc_id = aws_vpc.KiQ_Project.id
  }
}

resource "aws_route53_record" "route53_association" {
  zone_id = aws_route53_zone.KiQ_DN.zone_id
  name    = "kiqtrainingcenter.ink"
  type    = "A"

  alias {
    name = aws_lb.KiQ-ALB.dns_name
    zone_id = aws_lb.KiQ-ALB.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "rds_private" {
  zone_id = aws_route53_zone.KiQ_private_DN.zone_id
  name    = "db.kiqtrainingcenter.ink"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.KiQ_db.address]
}


