variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_id" {}
variable "Identity" {}

resource "aws_key_pair" "training" {
  key_name   = "${var.Identity}-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

variable "num_webs" {
	default = 3
}
resource "aws_instance" "web" {
  count = "${var.num_webs}"
	ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_id}"]
	key_name 							 = "${aws_key_pair.training.key_name}"
	
  tags = {
    Name       = "Rob Pountney ${count.index+1}/${var.num_webs}"
    training   = "Academy"
    "Identity" = "${var.Identity}"
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
}



output "public_ip" {
  value = "${aws_instance.web.*.public_ip}"
}
