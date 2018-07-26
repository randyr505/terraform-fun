#BEGIN
provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "../files/terraform_credentials"
  profile                 = "terraform"
  version = "~> 1.28"
}

# Create a VPC
resource "aws_vpc" "web" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Terraform = "true"
    Environment = "${var.application_environment}"
    Name = "${var.application_name}-vpc"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "../scripts/notify_slack.sh Terraform destroy completed"
  }
}

resource "aws_subnet" "web-private" {
    vpc_id = "${aws_vpc.web.id}"
    cidr_block = "${var.private_subnets}"
    availability_zone = "us-west-2a"

    tags {
      Name = "${var.application_name}-private-subnet"
    }
    depends_on = [ "aws_internet_gateway.igw" ]
}

resource "aws_subnet" "web-public" {
    vpc_id = "${aws_vpc.web.id}"
    cidr_block = "${var.public_subnets}"
    availability_zone = "us-west-2a"

    tags {
      Name = "${var.application_name}-public-subnet"
    }
    depends_on = [ "aws_internet_gateway.igw" ]
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex = "${var.ami_name_regex}"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#resource "aws_security_group" "bastion-sg" {
  #name = "${var.application_name}-bastion-sg"
  #vpc_id = "${aws_vpc.web.id}"
#
  #ingress {
    #protocol    = "tcp"
    #from_port   = 22
    #to_port     = 22
    #cidr_blocks = ["0.0.0.0/0"]
  #}
#
  #egress {
    #protocol    = -1
    #from_port   = 0
    #to_port     = 0
    #cidr_blocks = ["0.0.0.0/0"]
  #}
#}

#resource "aws_instance" "bastion" {
  #depends_on = ["aws_security_group.bastion-sg"]
  #ami           = "${data.aws_ami.ami.id}"
  #instance_type = "${var.ec2_instance_type}"
  #associate_public_ip_address = true
  #key_name = "${var.ssh_key_name}"
  ##security_groups = ["${aws_security_group.bastion-sg.id}"]
  #security_groups = ["sg-034850867413fc8cf"]
  #subnet_id = "${aws_subnet.web-public.id}"
#
  #tags {
    #Name = "${var.application_name}-bastion"
  #}
#}

resource "aws_autoscaling_group" "asg" {
  depends_on = ["aws_launch_configuration.web"]
  launch_configuration = "${aws_launch_configuration.web.id}"
  name = "${var.application_name}-web-asg"
  vpc_zone_identifier = [ "${aws_subnet.web-private.id}" ]
  desired_capacity = "${var.desired_capacity}"
  max_size = "${var.ec2_instance_max}"
  min_size = "${var.ec2_instance_min}"
  load_balancers = ["${aws_elb.web.name}"]
  health_check_type = "ELB"
  default_cooldown  = "${var.scaling_down_cooldown}"

  #provisioner "file" {
    #source = "upload/${var.index_name}"
    #destination = "/home/ec2-user"
#
    #connection {
      #type = "ssh"
      #host = "${self.private_ip}"
      #user = "ec2-user"
      #private_key = "${file("../files/randy-onica-key.pem")}"
      #bastion_host = "${aws_instance.bastion.public_ip}"
      #bastion_user = "ec2-user"
      #bastion_private_key = "${file("../files/randy-onica-key.pem")}"
    #}
  #}

  #provisioner "file" {
    #source = "upload/${var.lighttpd}"
    #destination = "/home/ec2-user"
#
    #connection {
      #type = "ssh"
      #host = "${self.private_ip}"
      #user = "ec2-user"
      #private_key = "${file("../files/randy-onica-key.pem")}"
      #bastion_host = "${aws_instance.bastion.public_ip}"
      #bastion_user = "ec2-user"
      #bastion_private_key = "${file("../files/randy-onica-key.pem")}"
    #}
  #}

  #provisioner "file" {
    #source = "upload/${var.gamin}"
    #destination = "/home/ec2-user"
#
    #connection {
      #type = "ssh"
      #host = "${self.private_ip}"
      #user = "ec2-user"
      #private_key = "${file("../files/randy-onica-key.pem")}"
      #bastion_host = "${aws_instance.bastion.public_ip}"
      #bastion_user = "ec2-user"
      #bastion_private_key = "${file("../files/randy-onica-key.pem")}"
    #}
  #}

  tag {
    key                 = "Name"
    value               = "${var.application_name}-web-instance"
    propagate_at_launch = true
  }
}

data "template_file" "user_data" {
  template = "${file("user_data.sh")}"

  vars {
    bucket_name   = "${var.bucket_name}"
    index_name = "${var.index_name}"
    pkgs = "${var.gamin} ${var.lighttpd}"
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name = "${var.ssh_key_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUHcSon/SV117hIbZXA0+aqXnkBmGTdJnon19M83mWvDFU0HKwPeTHvm4I0Eij2gbr+ySuP6PfT9EMH3zGzlK8LLyflS8wNfIHcamfVz/Ih++HdZT7plPXtp7FahA3nyjLXwHU/L2rWD3SGKUk4VcZY85paBiv49DWpGjOMWt/t7QDnvRMtotFclFR/oa1svrHsiHKWgnk8PqEqpTWh/znj9C0EnR1h3OWVkO03vDPrsjHwV0Arr0xT3uD4nquMk+shxRf53VYl9p54sI7UmZVX+vvF4BaoeLk+I6FOye5/na94anNtUlHru+sMhccEQFIO+fNWDaowHs2D1/kTmCv"
}

# COPY/PASTED
resource "aws_launch_configuration" "web" {
  image_id        = "${data.aws_ami.ami.id}"
  instance_type   = "${var.ec2_instance_type}"
  security_groups = ["${aws_security_group.ec2.id}"]
  user_data       = "${element(data.template_file.user_data.*.rendered, count.index)}"
  name = "${var.application_name}-web-lc"
  key_name = "${var.ssh_key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2" {
  name = "${var.application_name}-ec2-sg"
  vpc_id = "${aws_vpc.web.id}"

  # SSH access from public subnet (elb)
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.web-public.cidr_block}" ]
  }
  # HTTP access from the ELB
  ingress {
    from_port = "${var.web_port}"
    to_port = "${var.web_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.web-public.cidr_block}" ]
  }
  # Allow all from private subnet
  #ingress {
    #from_port   = 0
    #to_port     = 0
    #protocol    = "-1"
    #cidr_blocks = ["${aws_subnet.web-private.cidr_block}" ]
  #}

  #ingress {
    #from_port = "${var.web_port}"
    #to_port = "${var.web_port}"
    #protocol = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    #security_groups = ["${aws_security_group.elb.id}"]
  #}
  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #egress {
    #from_port = "${var.ssh_port}"
    #to_port = "${var.ssh_port}"
    #protocol = "tcp"
    #cidr_blocks = ["${var.my_ip_cidr}"]
    #cidr_blocks = ["${aws_subnet.web-public.cidr_block}" ]
  #}
  #egress {
    #from_port = "${var.web_port}"
    #to_port = "${var.web_port}"
    #protocol = "tcp"
    #cidr_blocks = ["${aws_subnet.web-public.cidr_block}" ]
  #}

  tags {
    Name = "${var.application_name}-ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ "aws_subnet.web-private" ]
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.web.id}"
    tags {
      Name = "${var.application_name}-web-igw"
    }
}

resource "aws_route" "internet_access" {
  route_table_id          = "${aws_vpc.web.main_route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.igw.id}"
}

resource "aws_elb" "web" {
  name = "${var.application_name}-web-elb"
  subnets = ["${aws_subnet.web-public.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  # Permission denied, otherwise works
  #access_logs {
    #bucket = "${var.bucket_name}"
    #bucket_prefix = "b"
    #interval = 5
  #}

  # Listen for incoming HTTP requests.
  listener {
    lb_port = "${var.elb_port}"
    lb_protocol = "http"
    instance_port = "${var.web_port}"
    instance_protocol = "http"
  }
}

resource "aws_security_group" "elb" {
  name = "${var.application_name}-elb-sg"
  vpc_id = "${aws_vpc.web.id}"

  # Outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all inbound HTTP
  ingress {
    from_port = "${var.elb_port}"
    to_port = "${var.elb_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip_cidr}"]
  }
  tags {
    Name = "${var.application_name}-elb-sg"
  }
}

resource "null_resource" "slack_destroy" {
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "../scripts/notify_slack.sh Terraform destroy has begun"
  }
}

#output "bastion_public_ip" {
  #value = "${aws_instance.bastion.public_ip}"
#}
