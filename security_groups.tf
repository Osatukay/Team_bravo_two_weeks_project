resource "aws_security_group" "load_balancer_security_group" {
  name        = "load_balancer_security_group"
  description = "Allow all public http and HTTPS traffic"
  vpc_id      = "vpc-080dbb0b7dc86503a"

  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "load_balancer_security_group"
  }

}

resource "aws_security_group" "bravo_nginx_server_security_group" {
  name        = "bravo_nginx_server_security_group"
  description = "Security group for nginx instance"
  vpc_id      = "vpc-080dbb0b7dc86503a"


  ingress {
    description = "HTTP"
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
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "bravo_nginx_server_security_group"
  }
}


resource "aws_security_group" "bravo_nginx_server_2_security_group" {
  name        = "bravo_nginx_server_2_security_group"
  description = "Security group for nginx instance"
  vpc_id      = "vpc-080dbb0b7dc86503a"


  ingress {
    description = "HTTP"
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
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "bravo_nginx_server_2_security_group"
  }
}


resource "aws_security_group" "bravo_hosp_lambda_security_group" {
  name        = "bravo_hosp_lambda_security_group"
  description = "Security group for lambda function"
  vpc_id      = "vpc-080dbb0b7dc86503a"

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "bravo_hosp_lambda_security_group"
  }
}