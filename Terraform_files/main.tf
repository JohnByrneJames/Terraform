# This is to launch an AMI on AWS using Terraform

# What do we want to do any where would we like to create the instance

# Syntax for terraform is similar to json - we use { to write block of code} 

provider "aws" {
# Which region do we have the AMI available - [Ireland | eu-west-1] 
	region = var.region
}

# Create a instance - launch an instance from the AMI we have provided
resource "aws_instance" "app_instance" {
	ami = var.ami_id

# What kind of Instance do we want to create [t2.micro]
	instance_type = var.instance_type

# Assign the instance a public ip
	associate_public_ip_address = true

# Assign the instance a tag E.G. a name
	tags = {
		Name = "Eng67.John.Terraform"
	}
} 

# We are creating a VPC now through Terraform

# Create a subnet block of code
# Attach this subnet to DevopsStudent VPC ()
# Create a security group SG Attach it to our VPC
# Create Ingress block of code to allow port 80 and 0.0.0.0/0
# Create Egress block of code to allow all 0.0.0.0/0 ::/0

# In the case we were creating our own VPC ~V~
#resource "aws_vpc" "default" {
#	cidr_block = "000.00.0.0/16"
#	enable_dns_support = true
#	enable_dns_hostnames = true
#}

# 1. Create Security Group

resource "aws_security_group" "allow_tls" {
	name = "Eng67_John_Terraform_SG"
	description = "This is the SG I from my Terraform on Premise"
	vpc_id = var.vpc_id

	ingress {
		description = "Allow all traffic from port 80 [HTTP]"
  	  	from_port = 80
  	  	to_port = 80
  	  	protocol = "tcp"
  	  	cidr_blocks = ["0.0.0.0/0"]
	}

    egress {
    	description = "Allow all Traffic to exit the vpc"
    	from_port = 0
  	    to_port = 0
  	    protocol = "-1"  # Semantically equivelant to all
  	    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    	Name = "Terraform formed SG and Rules" 
  }
}

# 2. Creating an internet Gateway

#resource "aws_internet_gateway" "default" {
#	vpc_id = var.vpc_id
#}

# 3. Create a PRIVATE and PUBLIC subnet

resource "aws_subnet" "private" {
	vpc_id = var.vpc_id
	cidr_block = var.private_subnet_cidr_block

	tags = {
		Name = "John_Terraformed_Private_Subnet"
	}
}

resource "aws_subnet" "public" {
	vpc_id = var.vpc_id
	cidr_block = var.public_subnet_cidr_block

	tags = {
		Name = "John_Terraformed_Public_Subnet"
	}
}


# 4. Create Network ACLs for the PRIVATE and PUBLIC subnets

resource "aws_network_acl" "private_NACL" {
	vpc_id = var.vpc_id
	subnet_ids = var.private_subnet_ID

	ingress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = var.public_subnet_cidr_block
		from_port = "22"
		to_port = "22"
	}

	ingress {
		protocol = "tcp"
		rule_no = 101
		action = "allow"
		cidr_block = var.public_subnet_cidr_block
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
		Name = "Eng67_John_Private_NACL"
	}
}

resource "aws_network_acl" "public_NACL" {
	vpc_id = var.vpc_id
	subnet_ids = var.public_subnet_ID

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
		cidr_block = var.private_subnet_cidr_block
		from_port = "27107"
		to_port = "27107"
	}

	egress {
		protocol = "tcp"
		rule_no = 102
		action = "allow"
		cidr_block = var.private_subnet_cidr_block
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
		Name = "Eng67_John_Public_NACL"
	}
}

# 5. Create a Route Table for Private and Public Subnets

resource "aws_route_table" "PrivateSubRoute" {
	vpc_id = var.vpc_id
}