terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_backup_vault" "backup_vault_4HR" {
  name = "backup_vault_4HR"

  tags = {
    "Plan" = "4HR"
  }
}

data "aws_iam_policy_document" "backup_vault_4HR_access_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["238543951586"]
    }

    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications",
    ]

    resources = [aws_backup_vault.backup_vault_4HR.arn]
  }
}

resource "aws_backup_vault_policy" "backup_vault_4HR_access_policy" {
  backup_vault_name = aws_backup_vault.backup_vault_4HR.name
  policy            = data.aws_iam_policy_document.backup_vault_4HR_access_policy_document.json
}

resource "aws_backup_plan" "backup_plan_4HR" {
  name = "backup_plan_4HR"

  rule {
    rule_name         = "Every_4HRs"
    target_vault_name = aws_backup_vault.backup_vault_4HR.name
    schedule          = "cron(0 0/1 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }

  tags = {
    Plan = "4HR"
  }
}

resource "aws_backup_selection" "backup_selection_4HR" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "backup_selection_4HR"
  plan_id      = aws_backup_plan.backup_plan_4HR.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "4HR"
  }
}

data "aws_iam_policy_document" "backup_service_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "backup_role" {
  name               = "test_backup_role"
  assume_role_policy = data.aws_iam_policy_document.backup_service_assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_iam_role_policy_attachment" "s3_backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_iam_role_policy_attachment" "s3_restore_backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.backup_role.name
}

resource "aws_s3_bucket" "backup_test_bucket" {
  bucket = "terraform-backups-test-bucket"

  tags = {
    backup = "4HR"
  }
}

resource "aws_s3_bucket_versioning" "backup_test_bucket_versioning" {
  bucket = aws_s3_bucket.backup_test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
