resource "aws_s3_bucket" "fawaz-tfe-es-s3" {
  bucket = "fawaz-tfe-es-s3"

  tags = {
    Name = "fawaz-tfe-es-s3"
  }
}

resource "aws_s3_bucket_acl" "fawaz-tfe-es-s3-acl" {
  bucket = aws_s3_bucket.fawaz-tfe-es-s3.id
  acl    = "private"
}

resource "aws_iam_instance_profile" "fawaz-tfe-es-inst" {
  name = "fawaz-tfe-es-inst"
  role = aws_iam_role.fawaz-tfe-es-role.name
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "my-bucket-policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::fawaz-tfe-es-s3/*",
          "arn:aws:s3:::fawaz-tfe-es-s3"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "fawaz-tfe-es-role" {
  name = "fawaz-tfe-es-role"

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
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "some_bucket_policy" {
  role       = aws_iam_role.fawaz-tfe-es-role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}
