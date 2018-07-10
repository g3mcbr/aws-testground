# /elknetwork/main.tf

provider "aws" {
  region = "${var.AWS_REGION}"
}

module "vpc" {
  source    = "../modules/network/vpc-with-nat-instance"
  app_name  = "${var.app_name}"
  app_env   = "${var.app_env}"
  aws_zones = "${var.aws_zones}"
  key_name  = "${var.key_name}"

  #  ecsTaskRoleAssumeRolePolicy       = "${var.ecsTaskRoleAssumeRolePolicy}"
  #  ecsTaskRolePolicy                 = "${var.ecsTaskRolePolicy}"
  src_ips = "${var.src_ips}"

  nat_sg_ids = ["${module.vpc.vpc_default_sg_id}", "${aws_security_group.allow-ssh.id}"]
}

module "ecscluster" {
  source                          = "github.com/silinternational/terraform-modules//aws/ecs/cluster"
  app_name                        = "${var.app_name}"
  app_env                         = "${var.app_env}"
  ecsInstanceRoleAssumeRolePolicy = "${var.ecsInstanceRoleAssumeRolePolicy}"
  ecsInstancerolePolicy           = "${var.ecsInstancerolePolicy}"
}

# module "external_elb" {
#   source    = "../modules/network/elb"
#   app_name  = "${var.app_name}"
#   app_env   = "${var.app_env}"
#   elb_name  = "${var.external_elb}"
#   sg_groups = ["${module.vpc.vpc_default_sg_id}", "${aws_security_group.ext-elb-inbound.id}"]
#   subnets   = "${module.vpc.public_subnet_ids}"
#   internal  = false
#
#   listener = [
#     {
#       lb_port           = 443
#       lb_protocol       = "http"
#       instance_port     = 80
#       instance_protocol = "http"
#     },
#   ]
#
#   health_check = [
#     {
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       timeout             = 3
#       target              = "HTTP:80/"
#       interval            = 30
#     },
#   ]
# }

data "aws_acm_certificate" "donotpassgo" {
  domain   = "*.donotpassgo.net"
  statuses = ["ISSUED"]
}

module "alb" {
  source          = "github.com/silinternational/terraform-modules//aws/alb"
  app_name        = "${var.app_name}"
  app_env         = "${var.app_env}"
  vpc_id          = "${module.vpc.id}"
  security_groups = ["${module.vpc.vpc_default_sg_id}", "${aws_security_group.ext-elb-inbound.id}"]
  subnets         = ["${module.vpc.public_subnet_ids}"]
  certificate_arn = "${data.aws_acm_certificate.donotpassgo.arn}"
}

# security group for external elb
resource "aws_security_group" "ext-elb-inbound" {
  vpc_id      = "${module.vpc.id}"
  name        = "${var.app_name}-${var.app_env}-ext-elb-inbound"
  description = "security group that allows ${var.app_name} traffic to public elb"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.src_ips}"]
  }

  tags {
    Name = "${var.app_name}-${var.app_env}-alb-inbound"
  }
}

resource "aws_security_group" "allow-ssh" {
  vpc_id      = "${module.vpc.id}"
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.src_ips}"]
  }

  tags {
    Name = "allow-ssh"
  }
}

/*
 * Test creating a new task role.  Will move this later.
 */

resource "random_id" "code" {
  byte_length = 4
}

resource "aws_iam_role" "ecsTaskRole" {
  name               = "ecsTaskRole-${random_id.code.hex}"
  assume_role_policy = "${var.ecsTaskRoleAssumeRolePolicy}"
}

resource "aws_iam_role_policy" "ecsTaskRolePolicy" {
  name   = "ecsTaskRolePolicy-${random_id.code.hex}"
  role   = "${aws_iam_role.ecsTaskRole.id}"
  policy = "${var.ecsTaskRolePolicy}"
}

data "aws_route53_zone" "donotpassgo" {
  name = "donotpassgo.net."
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.donotpassgo.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "120"
  records = ["${module.alb.dns_name}"]
}

terraform {
  backend "s3" {
    bucket = "tf-up-and-running-state"
    key    = "dev/testground/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
