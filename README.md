# MBA XPE Cloud Computing

## Finalidade
<p>Provisionar a insfraestrutura necessária referente ao MBA e efetuar a gestão de todo o ciclo de vida.</p>

## Requisitos
<p>HashiCorp Terraform: https://developer.hashicorp.com/terraform/downloads.</p>
<p>AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html.</p>
<p>Chave de acesso: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console#Using_CreateAccessKey.</p>

## Gerenciando a infra com o Terraform
<p>terraform validate - validar o arquivo de configuração main.tf.</p>
<p>terraform plan - opcional para criar e avaliar o plano de execução.</p>
<p>terraform apply - para provisionar da infra.</p>
<p>terraform refresh - atualizar o arquivo de estado da infra.</p>
<p>terraform destroy - para deprovisionar a infra.</p>