variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_id" {}
variable "Identity" {}
variable "region" {}
variable "volume" {
	default = 10
}
variable "availability_zone" {}

resource "aws_key_pair" "training" {
  key_name   = "${var.Identity}-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

variable "node_count" {
	default = 3
}
resource "aws_instance" "web" {
  count = "${var.node_count}"
	ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
	vpc_security_group_ids = ["${var.vpc_security_group_id}", "${aws_security_group.sg1.id}"]
	key_name 							 = "${aws_key_pair.training.key_name}"
  availability_zone 		 = "${var.availability_zone}"	
  tags = {
    Name        = "Rob Pountney Use Case ${count.index+1}/${var.node_count}"
    training    = "Academy"
    Identity    = "${var.Identity}"
  }

	connection {
    user     = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

	provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh"
    ]
  }


  root_block_device = {
    volume_size           = "${var.volume}"
  }

}


resource "aws_security_group" "sg1" {
  name        = "Rob Use Case Security Group 1"
  description = "blah"
  vpc_id      = "vpc-00e3bf973de77d348"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = 6
		cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
	ingress {
    from_port   = 22
    to_port     = 22
    protocol    = 6
    cidr_blocks     = ["212.250.145.34/32"]

  }

}

resource "aws_ebs_volume" "vol_generic_data" {
	availability_zone = "${var.availability_zone}"	
  size              = "${var.volume}"
  count             = 6
}

resource "aws_volume_attachment" "generic_data_vol_att" {
  device_name = "/dev/xvdf"
  volume_id   = "${element(aws_ebs_volume.vol_generic_data.*.id, count.index)}"
  instance_id = "${element(aws_instance.web.*.id, count.index)}"
  count       = "${var.node_count}"
}
resource "aws_volume_attachment" "generic_data_vol_att2" {
  device_name = "/dev/xvdg"
  volume_id   = "${element(aws_ebs_volume.vol_generic_data.*.id, count.index + 3)}"
  instance_id = "${element(aws_instance.web.*.id, count.index)}"
  count       = "${var.node_count}"
}
output "public_ip" {
  value = "${aws_instance.web.*.public_ip}"
}

output "security_group" {
	value = "${aws_security_group.sg1.id}"

}
