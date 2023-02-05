# Para simplificar, toda a infraestrutura será definida em um único arquivo.
# Mas a boa prática, para melhor entendimento e organização do código,
# seria criar arquivos específicos para cada componente de infra.
###########

# Define o provedor AWS maior ou igual a versão 4.53.0.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.53.0"
    }
  }
}

# Configura o provedor AWS.
# Para evitar a exposição das credenciais de acesso à AWS, adicionei os dados
# no arquivo credentials do diretório .aws que está configurado no .gitignore.
# Por questões de custo, deixei configurado a região Norte da Virgínia.
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  default_tags {
    tags = {
      Curso = "XPe"
    }
  }
}

# Criar os recursos do trabalho prático do módulo1.
###########

# Cria os grupos so-adm e db-adm e os usuários user1,
# user2 e user3.
resource "aws_iam_group_membership" "so-adm" {
  name = "so-adm-member"

  users = [
    aws_iam_user.user_one.name,
    aws_iam_user.user_two.name,
  ]

  group = aws_iam_group.group_one.name
}

resource "aws_iam_group" "group_one" {
  name = "so-adm"
}

resource "aws_iam_user" "user_one" {
  name = "user1"
}

resource "aws_iam_user" "user_two" {
  name = "user2"
}

resource "aws_iam_group_membership" "db-adm" {
  name = "db-adm-member"

  users = [
    aws_iam_user.user_three.name,
  ]

  group = aws_iam_group.group_two.name
}

resource "aws_iam_group" "group_two" {
  name = "db-adm"
}

resource "aws_iam_user" "user_three" {
  name = "user3"
}

# Ajustar as politicas dos grupos so-adm e db-adm.

resource "aws_iam_group_policy_attachment" "attach_policy_group_one" {
  group      = aws_iam_group.group_one.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "attach_policy_group_two" {
  group      = aws_iam_group.group_two.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Cria o VPC xpe-vpc-mod1 e configurações de rede para provisionamento da infra.
resource "aws_vpc" "xpe-vpc-mod1" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "xpe-subnet-mod1-privada1" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.0.0/23"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "xpe-subnet-mod1-privada2" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.0.0/23"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "xpe-subnet-mod1-privada3" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.0.0/23"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "xpe-subnet-mod1-publica1" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.10.0/23"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "xpe-subnet-mod1-publica2" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.10.0/23"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "xpe-subnet-mod1-publica3" {
  vpc_id     = aws_vpc.xpe-vpc-mod1.id
  cidr_block = "10.1.10.0/23"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "xpe-gw-mod1" {
  vpc_id = aws_vpc.xpe-vpc-mod1.id
}

resource "aws_route_table" "xpe-rt-mod1" {
  vpc_id = aws_vpc.xpe-vpc-mod1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xpe-gw-mod1.id
  }
}

resource "aws_route_table_association" "xpe-rt-mod1-association1" {
  subnet_id      = aws_subnet.xpe-subnet-mod1-publica1.id
  route_table_id = aws_route_table.xpe-rt-mod1.id
}

resource "aws_route_table_association" "xpe-rt-mod1-association2" {
  subnet_id      = aws_subnet.xpe-subnet-mod1-publica2.id
  route_table_id = aws_route_table.xpe-rt-mod1.id
}

resource "aws_route_table_association" "xpe-rt-mod1-association3" {
  subnet_id      = aws_subnet.xpe-subnet-mod1-publica3.id
  route_table_id = aws_route_table.xpe-rt-mod1.id
}

resource "aws_security_group" "xpe-sg-mod1" {
  name        = "xpe-sg-mod1"
  description = "Controla acessos aos recursos da infra."
  vpc_id      = aws_vpc.xpe-vpc-mod1.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria as instancias EC2 web1, web2 e web3.
resource "aws_instance" "xpe-ec2-web1" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "xpe-key-ec2"
  security_groups             = aws_security_group.xpe-sg-mod1.id
  subnet_id                   = aws_subnet.xpe-subnet-mod1-publica1.id
}

resource "aws_instance" "xpe-ec2-web2" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "xpe-key-ec2"
  security_groups             = aws_security_group.xpe-sg-mod1.id
  subnet_id                   = aws_subnet.xpe-subnet-mod1-publica2.id
}

resource "aws_instance" "xpe-ec2-web3" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "xpe-key-ec2"
  security_groups             = aws_security_group.xpe-sg-mod1.id
  subnet_id                   = aws_subnet.xpe-subnet-mod1-publica3.id
}