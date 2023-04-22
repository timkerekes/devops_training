resource "aws_organizations_organization" "devopswithtim" {

}

resource "aws_organizations_organizational_unit" "dev" {
  name      = "DEV"
  parent_id = aws_organizations_organization.devopswithtim.roots[0].id
}

resource "aws_organizations_organizational_unit" "test" {
  name      = "TEST"
  parent_id = aws_organizations_organization.devopswithtim.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "PROD"
  parent_id = aws_organizations_organization.devopswithtim.roots[0].id
}

resource "aws_organizations_account" "dev-account" {
  name  = var.dev_name
  email = var.dev_email
  parent_id = aws_organizations_organizational_unit.dev.id
}

resource "aws_organizations_account" "test-account" {
  name  = var.test_name
  email = var.test_email
  parent_id = aws_organizations_organizational_unit.test.id
}

resource "aws_organizations_account" "prod-account" {
  name  = var.prod_name
  email = var.prod_email
  parent_id = aws_organizations_organizational_unit.prod.id
}