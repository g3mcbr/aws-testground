variable "AWS_REGION" {
  default = "us-east-1"
}

variable "app_name" {
  type    = "string"
  default = "web"
}

variable "app_env" {
  type    = "string"
  default = "test"
}

#variable "cluster" {
#  type    = "string"
#  default = "ecs_elk-test"
#}

#variable "external_elb_name" {
#  type    = "string"
#  default = "elk-test-external-elb"
#}

variable "desired_count" {
  type    = "string"
  default = "2"
}

variable "container_name" {
  type    = "string"
  default = "web"
}

variable "container_port" {
  type    = "string"
  default = "80"
}

variable "subdomain" {
  type    = "string"
  default = "www"
}

variable "base_domain" {
  type    = "string"
  default = "donotpassgo.net"
}

#######################################
variable "vpc_remote_state_bucket" {
  default = "tf-up-and-running-state"
}

variable "vpc_remote_state_key" {
  default = "dev/testground/vpc/terraform.tfstate"
}

variable "cluster_remote_state_bucket" {
  default = "tf-up-and-running-state"
}

variable "cluster_remote_state_key" {
  default = "dev/testground/cluster/terraform.tfstate"
}

#variable "lb_remote_state_bucket" {
#  default = "tf-up-and-running-state"
#}


#variable "lb_remote_state_key" {
#  default = "dev/elktest/loadbalancers/terraform.tfstate"
#}

