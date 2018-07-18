# /kibana/main.tf

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

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config {
    bucket = "${var.cluster_remote_state_bucket}"
    key    = "${var.cluster_remote_state_key}"
    region = "${var.AWS_REGION}"
  }
}

resource "aws_alb_listener_rule" "https" {
  listener_arn = "${data.terraform_remote_state.newvpc.alb_https_listener_arn}"
  priority     = "205"

  action {
    type             = "forward"
    target_group_arn = "${data.terraform_remote_state.newvpc.default_tg_arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.subdomain}.${var.base_domain}"]
  }
}

/*
 * Create task definition templates
 */
data "template_file" "task_def" {
  template = "${file("${path.module}/task-def.json")}"

  vars {}
}

# below uses sil service module
module "ecsservice_https" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only"
  cluster_id         = "${data.terraform_remote_state.newvpc.ecs_cluster_id}"
  service_name       = "${var.app_name}-https"
  service_env        = "${data.terraform_remote_state.newvpc.app_env}"
  container_def_json = "${data.template_file.task_def.rendered}"
  desired_count      = "${var.desired_count}"
  tg_arn             = "${data.terraform_remote_state.newvpc.default_tg_arn}"
  lb_container_name  = "${var.container_name}"
  lb_container_port  = "${var.container_port}"
  ecsServiceRole_arn = "${data.terraform_remote_state.newvpc.ecsServiceRole_arn}"
}

module "ecsservice_http" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only"
  cluster_id         = "${data.terraform_remote_state.newvpc.ecs_cluster_id}"
  service_name       = "${var.app_name}-http"
  service_env        = "${data.terraform_remote_state.newvpc.app_env}"
  container_def_json = "${file("${path.module}/task-def-http-to-https.json")}"
  desired_count      = "${var.desired_count}"
  tg_arn             = "${data.terraform_remote_state.newvpc.alb_default_http_tg_arn}"
  lb_container_name  = "http-to-https"
  lb_container_port  = "${var.container_port}"
  ecsServiceRole_arn = "${data.terraform_remote_state.newvpc.ecsServiceRole_arn}"
}

terraform {
  backend "s3" {
    bucket = "tf-up-and-running-state"
    key    = "dev/testground/webapp/terraform.tfstate"
    region = "us-east-1"
  }
}
