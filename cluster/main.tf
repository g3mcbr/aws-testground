# /cluster/main.tf

provider "aws" {
  region = "${var.AWS_REGION}"
}

data "terraform_remote_state" "newvpc" {
  backend = "s3"

  config {
    bucket = "${var.vpc_remote_state_bucket}"
    key    = "${var.vpc_remote_state_key}"
    region = "${var.AWS_REGION}"
  }
}

module "cluster" {
  source             = "../modules/compute/cluster"
  instance_type      = "${var.instance_type}"
  app_name           = "${data.terraform_remote_state.newvpc.app_name}"
  app_env            = "${data.terraform_remote_state.newvpc.app_env}"
  cluster_name       = "${data.terraform_remote_state.newvpc.ecs_cluster_name}"
  ami_id             = "${data.terraform_remote_state.newvpc.ami_id}"
  vpc_id             = "${data.terraform_remote_state.newvpc.vpc_id}"
  sg_groups          = ["${data.terraform_remote_state.newvpc.vpc_default_sg_id}"]
  aws_zones          = "${data.terraform_remote_state.newvpc.aws_zones}"
  private_subnet_ids = "${data.terraform_remote_state.newvpc.private_subnet_ids}"
  key_name           = "${var.key_name}"

  #ip_value                  = 100
  user_data_script = "ecs_user_data.sh"

  #  instance_count            = 2
  instance_count       = "${length(data.terraform_remote_state.newvpc.private_subnet_ids)}"
  iam_instance_profile = "${data.terraform_remote_state.newvpc.ecs_instance_profile_id}"
  vol_count            = 0
  vol_id               = []

  tags = {
    "Name"     = "docker_ecs_host"
    "logstash" = "lsnode"
  }
}

terraform {
  backend "s3" {
    bucket = "tf-up-and-running-state"
    key    = "dev/testground/cluster/terraform.tfstate"
    region = "us-east-1"
  }
}
