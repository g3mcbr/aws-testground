output "app_name" {
  value = "${var.app_name}"
}

output "app_env" {
  value = "${var.app_env}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "aws_zones" {
  value = ["${module.vpc.aws_zones}"]
}

output "vpc_default_sg_id" {
  value = "${module.vpc.vpc_default_sg_id}"
}

output "public_subnet_ids" {
  value = ["${module.vpc.public_subnet_ids}"]
}

output "private_subnet_ids" {
  value = ["${module.vpc.private_subnet_ids}"]
}

#output "external_elb_name" {
#  value = "${module.external_elb.elb_name}"
#}
output "external_alb_id" {
  value = "${module.alb.id}"
}

output "external_alb_arn" {
  value = "${module.alb.arn}"
}

#output "external_elb_dns_name" {
#  value = "${module.external_elb.elb_dns_name}"
#}
output "external_alb_dns_name" {
  value = "${module.alb.dns_name}"
}

output "ext_elb_sg_id" {
  value = "${aws_security_group.ext-elb-inbound.id}"
}

output "ecs_instance_profile_id" {
  value = "${module.ecscluster.ecs_instance_profile_id}"
}

output "ecs_cluster_name" {
  value = "${module.ecscluster.ecs_cluster_name}"
}

output "ecs_cluster_id" {
  value = "${module.ecscluster.ecs_cluster_id}"
}

output "ami_id" {
  value = "${module.ecscluster.ami_id}"
}

output "ecsServiceRole_arn" {
  value = "${module.ecscluster.ecsServiceRole_arn}"
}

output "ecsInstanceRole_arn" {
  value = "${module.ecscluster.ecsInstanceRole_arn}"
}

output "nat_instance_ip" {
  value = "${module.vpc.nat_instance_ip}"
}

output "ecsTaskRole_arn" {
  #  value = "${module.vpc.ecsTaskRole_arn}"
  value = "${aws_iam_role.ecsTaskRole.arn}"
}

output "alb_https_listener_arn" {
  value = "${module.alb.https_listener_arn}"
}
