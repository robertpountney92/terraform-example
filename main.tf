variable "access_key" {
	type = "string"
}

variable "secret_key" {
	type = "string"
}

variable "region" {
	type = "string"
	default = "eu-west-1"
}

variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_id" {}
variable "Identity" {}
variable "volume" {}
variable "availability_zone" {}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "use_case" {
	source = "./use_case"
	ami 										= "${var.ami}"
	instance_type 					= "${var.instance_type}"
	subnet_id              	= "${var.subnet_id}"
  vpc_security_group_id 	= "${var.vpc_security_group_id}"
  Identity 								= "${var.Identity}"	
	volume									= "${var.volume}"
	region									= "${var.region}"
	availability_zone				= "${var.availability_zone}"
}

output "public_ip" {
  value = "${module.use_case.public_ip}"
}

