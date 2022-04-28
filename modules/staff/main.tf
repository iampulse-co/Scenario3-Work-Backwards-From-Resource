# APAC team role
resource "aws_iam_role" "APAC-Team" {
  name = "APAC-Team"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

// NOTE FOR IAM PULSE: This policy sounds like it'd grant the access, but it does not
resource "aws_iam_role_policy_attachment" "apac_full_rds_access_data" {
  role       = aws_iam_role.APAC-Team.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

# EMEA team role
resource "aws_iam_role" "EMEA-Team" {
  name                 = "EMEA-Team"
  max_session_duration = "3600"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com",
          #AWS = "arn:aws:sts::947197796922:assumed-role/AWSReservedSSO_AdministratorAccess_163bbd01088aba47/kyler.middleton"
        }
      }
    ]
  })
}

// IAM PULSE INFO: This policy reads like it should permit the rds:connect action
// However, it doesn't. The deny matches are evaluated first, so this group isn't permitted
resource "aws_iam_policy" "emea_team_policy" {
  name        = "EMEA-Team-Policy"
  description = "EMEA Team policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PermitAllActions"
          "Action" : "*"
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Sid" : "ButNotRdsStuff"
          "Action" : [
            "rds:*",
          ],
          "Effect" : "Deny",
          "Resource" : "arn:aws:rds:us-east-2:947197796922:db:scenario-three-rds"
        },
        {
          "Sid" : "ExceptRdsDbConnectPermitThatOne"
          "Action" : [
            "rds-db:connect"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:rds:us-east-2:947197796922:db:scenario-three-rds"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "EMEA-Team-Custom-IAM" {
  role       = aws_iam_role.EMEA-Team.name
  policy_arn = aws_iam_policy.emea_team_policy.arn
}


# LATAM team role
resource "aws_iam_role" "LATAM-Team" {
  name                 = "LATAM-Team"
  max_session_duration = "3600"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com",
        }
      }
    ]
  })
}

resource "aws_iam_policy" "latam_team_policy" {
  name        = "LATAM-Team-Policy"
  description = "LATAM Team policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowAllResourcesInDevEnv"
          "Action" : "*",
          "Effect" : "Allow",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:ResourceTag/Environment" : "dev"
            }
          }
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "LATAM-Team-Custom-IAM" {
  role       = aws_iam_role.LATAM-Team.name
  policy_arn = aws_iam_policy.latam_team_policy.arn
}
