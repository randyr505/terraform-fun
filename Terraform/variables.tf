# GLOBAL VARIABLES
#BEGIN

variable "application_name" {
  description = "Name of the application, serves as a naming prefix for all Terraform-generated resources."
  default     = "Randy-Onica"
}

variable "application_environment" {
  description = "Environment of the application, serves as a naming identifier for all Terraform-generated resources. Not to be confused with AWS environment."
  default = "Dev"
}

variable "aws_region" {
  description = "AWS region used by the AWS provider as a differentiator for environment mappings."
  default = "us-west-2"
}

variable "desired_capacity" {
  description = "Desired number of instances in a cluster"
  default = "3"
}

variable "owner_contact_tag" {
  description = "Owner contact email of the application to be tagged on AWS resources."
  default     = "me@example.com"
}

variable "vpc_cidr" {
  default = "10.15.0.0/23"
}

variable "my_ip_cidr" {
  description = "update with your computer's ip address"
  default = "0.0.0.15/32"
}

variable "public_subnets" {
  default = "10.15.1.0/24"
}

variable "private_subnets" {
  default = "10.15.0.0/24"
}

variable "ssh_key_name" {
  description = "SSH Key pair name"
  default = "randy-onica-key"
}

variable "web_packages" {
  description = "Packages to upload to s3 and install via user_data"
  default = "gamin-0.1.10-16.14.amzn1.x86_64.rpm lighttpd-1.4.41-1.34.amzn1.x86_64.rpm"
}

# EC2 VARIABLES

variable "bucket_name" {
  description = "The build-time S3 bucket for which the instance will retrieve the Chef cookbook from during instance bootstrapping."
  default = "randys-bucket-2018072216"
}

variable "index_name" {
  description = "The name of index_html in s3"
  default = "index.html"
}
variable "gamin" {
  description = "The gamin package to upload in s3"
  default = "gamin-0.1.10-16.14.amzn1.x86_64.rpm"
}
variable "lighttpd" {
  description = "The lighttpd package to upload in s3"
  default = "lighttpd-1.4.41-1.34.amzn1.x86_64.rpm"
}

variable "elb_port" {
  description = "Port of ELB"
  default = "80"
}

variable "web_port" {
  description = "Port of website"
  default = "80"
}

variable "ssh_port" {
  description = "Port for ssh"
  default = "22"
}

variable "load_balancer_access_log_bucket_name" {
  description = "The S3 bucket name to store the application load balancer logs in."
  default = "elb-access-logs"
}

variable "instance_type" {
  description = "The size of instance to launch."
  default     = "t2.micro"
}

# AUTOSCALING VARIABLES

variable "scaling_down_cooldown" {
  description = "The amount of time, in seconds, after a downscaling activity completes and before the next downscaling activity can start."
  default     = "60"
}

# AMI
variable "ami_name_regex" {
  description = "A regex string to apply to the AMI list returned by AWS. This allows more advanced filtering not supported from the AWS API. This filtering is done locally on what AWS returns, and could have a performance impact if the result list is exceptionally large."
  #default     = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-\\d{8}"
  #default     = "amzn-ami-hvm-2018.03.0.20180622-x86_64-gp2"
  #default     = "^amzn-ami-hvm-2018.03.0.\\d{8}-x86_64-gp2"
  default     = "^ApacheLinux"
}

variable "ec2_instance_type" {
  description = "Type of ec2 instances"
  default     = "t2.micro"
}

variable "ec2_instance_min" {
  description = "Min number of ec2 instances"
  default     = "2"
}

variable "ec2_instance_max" {
  description = "Max number of ec2 instances"
  default     = "5"
}
