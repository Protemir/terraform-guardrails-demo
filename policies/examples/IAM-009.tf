# Пример для правила IAM-009: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_iam_policy" "bad_admin" {
  name   = "everything"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "*", "Resource": "*" }]
}
EOF
}

resource "aws_iam_policy" "good_read_bucket" {
  name   = "read-files"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": ["s3:GetObject"], "Resource": "arn:aws:s3:::shop-files/*" }]
}
EOF
}
