# This is to launch an AMI on AWS using Terraform

# What do we want to do any where would we like to create the instance

# Syntax for terraform is similar to json - we use { to write block of code} 

provider "aws" {
# Which region do we have the AMI available - [Ireland | eu-west-1] 
	region = var.region
}

resource "aws_vpc" "terraform_vpc" {
	cidr_block = var.cidr_block
	instance_tenancy = "default"

	tags = {
		Name = "Eng67-John-Terra-VPC"
	}
}

# Public --[Subnet]--

resource "aws_subnet" "terraform_public_subnet" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	cidr_block = var.pub_subnet_cidr_block
	map_public_ip_on_launch = "true"  # Makes this a public subnet
	availability_zone = var.avail_zone

	tags = {
		Name = "Eng67-John-Terra-Pub-SNet"
	}
}

resource "aws_internet_gateway" "terraform_igw" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	tags = {
		Name = "Eng67-John-Terra-IGW"
	}
}

resource "aws_route_table" "terraform_pub_route_table" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	route {
		# Associate subnet can reach everywhere
		cidr_block = "0.0.0.0/0"

		# CRT uses this IGW to reach internet
		gateway_id = "${aws_internet_gateway.terraform_igw.id}"
	}

	tags = {
		Name = "Eng67-John-Terra-Pub-RouteT"
	}	
}

resource "aws_route_table_association" "terraform_crt_public_subnet" {
	subnet_id = "${aws_subnet.terraform_public_subnet.id}"
	route_table_id = "${aws_route_table.terraform_pub_route_table.id}"
}

resource "aws_network_acl" "terraform_pub_NACL" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	subnet_ids = ["${aws_subnet.terraform_public_subnet.id}"]

	#ingress {
	#	protocol = "tcp"
	#	rule_no = 100
	#	action = "allow"
	#	cidr_block = "${MYIPV4}/32" 
	#	from_port = "22"
	#	to_port = "22"
	#}

	ingress {
		protocol = "tcp"
		rule_no = 101
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "80"
		to_port = "80"
	}

	ingress {
		protocol = "tcp"
		rule_no = 102
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "443"
		to_port = "443"
	}

	ingress {
		protocol = "tcp"
		rule_no = 103
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "1024"
		to_port = "65535"
	}

	egress {
		protocol = "tcp"
		rule_no = 101
		action = "allow"
		cidr_block = var.priv_subnet_cidr_block
		from_port = "27107"
		to_port = "27107"
	}

	egress {
		protocol = "tcp"
		rule_no = 102
		action = "allow"
		cidr_block = var.priv_subnet_cidr_block
		from_port = "1024"
		to_port = "65535"
	}

	egress {
		protocol = "tcp"
		rule_no = 103
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "80"
		to_port = "80"
	}

	egress {
		protocol = "tcp"
		rule_no = 104
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "443"
		to_port = "443"
	}


	tags = {
		Name = "Eng67-John-Terra-pub-NACL"
	}
}

# Private --[Subnet]--

resource "aws_subnet" "terraform_private_subnet" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	cidr_block = var.priv_subnet_cidr_block
	availability_zone = var.avail_zone

	tags = {
		Name = "Eng67-John-Terra-Priv-SNet"
	}
}

resource "aws_route_table" "terraform_priv_route_table" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	tags = {
		Name = "Eng67-John-Terra-Priv-RouteT"
	}
}

resource "aws_route_table_association" "terraform_crt_private_subnet"{
	subnet_id = "${aws_subnet.terraform_private_subnet.id}"
	route_table_id = "${aws_route_table.terraform_priv_route_table.id}"
}

resource "aws_network_acl" "terraform_priv_NACL" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	subnet_ids = ["${aws_subnet.terraform_private_subnet.id}"]

	ingress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = var.pub_subnet_cidr_block
		from_port = "22"
		to_port = "22"
	}

	ingress {
		protocol = "tcp"
		rule_no = 101
		action = "allow"
		cidr_block = var.pub_subnet_cidr_block
		from_port = "27107"
		to_port = "27107"
	}

	egress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = "27107"
		to_port = "27107"
	}

	tags = {
		Name = "Eng67-John-Terra-Priv-NACL"
	}
}

# --[VPC Security Group]--

resource "aws_security_group" "terraform_VPC_SG" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"

		# This means all IP addresses are allowed to ssh into the Machine..
		# This is dangerous, replace with specific IP
		# Put your office or home address in it
		cidr_blocks = var.my_ip
	}

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "Eng67-John-Terra-VPC-SG"
	}
}

# Create an EC2 Instance for an AMI image and then place it inside the public subnet

resource "aws_instance" "ec2_webapp_instance" {
	ami = "(var.AMI, var.region)" 
	instance_type = "t2.micro"

	# VPC
	subnet_id = "${aws_subnet.terraform_public_subnet.id}"

	# Security Group
	vpc_security_group_ids = ["${aws_security_group.terraform_VPC_SG.id}"]

	# public SSH key
	key_name = "${aws_key_pair.london-region-key-pair.id}"

	# NGINX installation for webapp
	provisioner "file" {
		source = "nginx"
		destination = "/home/ubuntu/environment/"
	}

	# Add app folder
	provisioner "file" {
		source = "app"
		destination = "/home/ubuntu/app/"
	}

	provisioner "remote-exec" {
		inline = [
			"chmod +x /home/ubuntu/environment/provision.sh",
			"sudo /home/ubuntu/environment/provision.sh"
		]
	}

	connection {
		user = "${var.EC2_USER}"  # Should default to root
		private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
		host = "${aws_instance.ec2_webapp_instance.public_ip}"
	}
}

// Sends your public key to the instance
resource "aws_key_pair" "london-region-key-pair" {
    key_name = "london-region-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

# Copy in App folder
# Copy in environment folder
# Run provisoner on ./home/ubuntu/environment/provision.sh