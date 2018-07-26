provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "../../terraform_credentials"
  profile                 = "terraform"
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.bucket_name}"
  #acl    = "private"

  tags {
    Name = "${var.bucket_name}"
    Enviornment = "${var.application_environment}"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::280835925849:user/Randy",
                "arn:aws:iam::280835925849:root"]
      },
      "Action": "s3:*",
      "Resource": ["arn:aws:s3:::${var.bucket_name}",
                   "arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
POLICY
}
