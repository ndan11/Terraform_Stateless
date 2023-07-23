module "codecommit" {

  source = "lgallard/codecommit/aws"

  repository_name = "Nandan-WildRydes"
  description     = "Via Terraform"

  tags = {
    Owner = "Nandan"
  }
}
