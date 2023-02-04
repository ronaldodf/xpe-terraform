# Para simplificar, toda a infraestrutura será definida em um único arquivo.
# Mas a boa prática, para melhor entendimento e organização do código,
# seria criar arquivos específicos para cada componente de infra.

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
provider "aws" {
  region = "us-east-1"
  shared_credentials_files = [".aws/credentials"]
}

# Criar os recursos do trabalho prático do módulo1.
# Cria os grupos so-adm e db-adm
resource "aws_iam_group" "so-adm" {
  name = "so-adm"
}

resource "aws_iam_group_policy_attachment" "so-adm-attach" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group" "db-adm" {
  name = "db-adm"
}

resource "aws_iam_group_policy_attachment" "db-adm-attach" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Cria os usuários user1, user2 e user3